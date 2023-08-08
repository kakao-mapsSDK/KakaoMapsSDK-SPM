#include <metal_stdlib>
#include <metal_texture>

using namespace metal;

constant float inverseWeight = 1.0/255.0;

struct __attribute((packed)) Vertex
{
    packed_float4 a_position;
    packed_uchar4 a_color;
};

struct VertexOutput
{
    float4 position [[position]];
    float2 texcoord;
    float4 diffuse;
};

struct VertexUniforms
{
    float4 u_viewport;
};

struct FragmentUniforms
{
    float4 u_dimmed_color;
};

vertex VertexOutput vertexFunc( const device Vertex *vertexIn [[buffer(0)]],
                                constant VertexUniforms &constUniforms [[buffer(1)]],
                                ushort vid [[vertex_id]] )
{
    VertexOutput output;
    
    output.texcoord = vertexIn[vid].a_position.zw;
    output.diffuse = float4(vertexIn[vid].a_color) * inverseWeight;
    
    output.position.x = vertexIn[vid].a_position.x * 2.0 / constUniforms.u_viewport.z - 1.0;
    output.position.y = (1.0 - vertexIn[vid].a_position.y / constUniforms.u_viewport.w) * 2.0 - 1.0;
    output.position.z = 0.0;
    output.position.w = 1.0;
    
    output.position.z = (output.position.z + output.position.w) / 2.0;
    
    return output;
}

[[early_fragment_tests]]
fragment half4 fragmentFunc( VertexOutput vert [[stage_in]],
                             constant FragmentUniforms &constUniforms [[buffer(0)]],
                             texture2d<float, access::sample> u_diffuse_texture [[texture(0)]],
                             sampler u_diffuse_sampler [[sampler(0)]])
{
    float4 diffuseColor = u_diffuse_texture.sample(u_diffuse_sampler, vert.texcoord);
    
    float alpha = constUniforms.u_dimmed_color.w * vert.diffuse.x;
    float3 dimmed_color = float3( constUniforms.u_dimmed_color.x * alpha,
                                  constUniforms.u_dimmed_color.y * alpha,
                                  constUniforms.u_dimmed_color.z * alpha );
    alpha = 1.0 - alpha;
    
    float3 color = float3( diffuseColor.x * alpha,
                           diffuseColor.y * alpha,
                           diffuseColor.z * alpha );
    
    return static_cast<half4>(float4(color + dimmed_color, vert.diffuse.w * diffuseColor.w));
}



