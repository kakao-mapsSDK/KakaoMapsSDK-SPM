#include <metal_stdlib>
#include <metal_texture>

using namespace metal;

struct __attribute((packed)) Vertex
{
    packed_float3 a_position;
    packed_float2 a_uv;
    packed_float2 a_uv2;
};

struct VertexOutput
{
    float4 position [[position]];
    float3 texcoord;
//    float2 depth;
};

struct VertexInstanceUniforms
{
    float u_distance_max;
    float4x4 u_mvp;
};

struct FragmentInstanceUniforms
{
    float4 u_diffuse_color;
};

float3 getNormal(float2 rg) {
    
    float tz = floor(rg.y / 64.0); //8 * 8
    float z = ((rg.x - floor(rg.x / 2.0) * 2.0) * 4.0) + tz;
    float y = floor((rg.y - tz * 64.0) / 8.0);
    float x = floor( rg.y - 8.0 * floor(rg.y / 8.0) );
    
    if (x > 3.0) { x += -8.0; }
    if (y > 3.0) { y += -8.0; }
    if (z > 3.0) { z += -8.0; }
    
    return float3(x, y, z);
}

float getDepth(float3 position, float2 uv, float maxValue, texture2d<float, access::sample> depth_texture, sampler depth_sampler) {
    if(uv.x > 0.98)
    {
        uv.x = 0.0;
    }
    
    float4 depthColor = depth_texture.sample(depth_sampler, uv);

    depthColor *= 255.0;
    
    float depth = pow(maxValue + 1.0, depthColor.b / 256.0) - 1.0;

    if ( depth <= 3.0 ) {
        float3 normal = getNormal(depthColor.rg);
        if( length(normal) == 0.0 )
//        if( uv.y < 0.6 )
        {
            depth = maxValue;
        }
        else
        {
            depth = 3.0 + 3.0 * (length(position) / abs(position.z) - 1.0);
        }
    }
    
    return depth;
}

vertex VertexOutput vertexFunc( const device Vertex *vertexIn [[buffer(0)]],
                                constant VertexInstanceUniforms &instanceUniforms [[buffer(1)]],
                                texture2d<float, access::sample> u_depth_texture [[texture(0)]],
                                sampler u_depth_sampler [[sampler(0)]],
                                ushort vid [[vertex_id]] )
{
    VertexOutput output;
    
    float3 position = vertexIn[vid].a_position;
    float depth = getDepth(position, vertexIn[vid].a_uv2, instanceUniforms.u_distance_max, u_depth_texture, u_depth_sampler);
    depth = 16.0;
//    output.depth.x = depth;
//    output.depth.y = instanceUniforms.u_distance_max;
    position *= depth;
    
    float3 texcoord = float3(vertexIn[vid].a_uv.xy, 1.0);
    texcoord *= length(position) / instanceUniforms.u_distance_max;
    
    output.texcoord = texcoord;
    output.position = instanceUniforms.u_mvp * float4( position, 1.0 );
    output.position.z = (output.position.z + output.position.w) / 2.0;
    
    return output;
}

[[early_fragment_tests]]
fragment half4 fragmentFunc( VertexOutput vert [[stage_in]],
                             constant FragmentInstanceUniforms &instanceUniforms [[buffer(0)]],
                             texture2d<float, access::sample> u_diffuse_texture [[texture(0)]],
                             sampler u_diffuse_sampler [[sampler(0)]])
{
    float2 texCoord = float2(vert.texcoord.xy / vert.texcoord.z);
    float4 realColor = u_diffuse_texture.sample(u_diffuse_sampler, texCoord);

    //    gl_FragColor = realColor * vec4(1.0 - diffuseColor.z);
    //    gl_FragColor = realColor * vec4(depthVarying.x/depthVarying.y, 0.5, 0.5, 1.0);
    
    realColor.a = instanceUniforms.u_diffuse_color.w * realColor.a;
    return static_cast<half4>(realColor);
}



