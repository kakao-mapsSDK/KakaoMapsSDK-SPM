#include <metal_stdlib>
#include <metal_texture>

using namespace metal;

struct __attribute((packed)) Vertex
{
    packed_float4 a_position;
    packed_float4 a_normal;
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

struct VertexInstanceUniforms
{
    float4 u_diffuse_color;
    float4 u_pixel_rotation;
    float4 u_pixel_translation_scale;
    float4 u_pixel_anchor;
    float4 u_sprite_space;
    float4x4 u_sprite_matrix;
    float4x4 u_mvp;
};

float3 rotate_vector( float4 quat, float3 vector )
{
    return vector + 2.0 * cross( cross( vector, quat.xyz ) + quat.w * vector, quat.xyz );
}

float4 calcPosition(float A, float B, float C, float D, float4x4 transform, float4 position)
{
    float4 currentPosition = transform * position;
    currentPosition /= currentPosition.w;

    float x = currentPosition.x * (2.0 / A) - D;
    float y = D - currentPosition.y * (2.0 / B);
    float z = -D + currentPosition.z * C;

    return float4(x, y, z, 1.0);
}

vertex VertexOutput vertexFunc( const device Vertex *vertexIn [[buffer(0)]],
                                constant VertexUniforms &constUniforms [[buffer(1)]],
                                constant VertexInstanceUniforms &instanceUniforms [[buffer(2)]],
                                ushort vid [[vertex_id]] )
{
    VertexOutput output;
    
    output.texcoord = vertexIn[vid].a_normal.zw;
        
    output.diffuse = float4( instanceUniforms.u_diffuse_color.xyz, vertexIn[vid].a_position.w * instanceUniforms.u_diffuse_color.w );


    //mat4 u_sprite_matrix = mat4(1.0);
    //vec4 u_sprite_space = instanceUniforms.u_viewport;
    float4 currentPosition = calcPosition(instanceUniforms.u_sprite_space.x,
                                          instanceUniforms.u_sprite_space.y,
                                          instanceUniforms.u_sprite_space.z,
                                          instanceUniforms.u_sprite_space.w,
                                          instanceUniforms.u_sprite_matrix,
                                          vertexIn[vid].a_position);

    float3 translation = rotate_vector( instanceUniforms.u_pixel_rotation, float3( vertexIn[vid].a_normal.xy, 0.0) );
    translation.xy *= instanceUniforms.u_pixel_translation_scale.zw;

    translation += rotate_vector( instanceUniforms.u_pixel_rotation, float3( instanceUniforms.u_pixel_anchor.xy, 0.0 ) );
    
    translation.xy += instanceUniforms.u_pixel_translation_scale.xy;

    output.position.x = currentPosition.x + ( translation.x / constUniforms.u_viewport.z ) * 2.0;
    output.position.y = currentPosition.y - ( translation.y / constUniforms.u_viewport.w ) * 2.0 ;
    output.position.zw = currentPosition.zw;
    
    output.position.z = (output.position.z + output.position.w) / 2.0;
    
    return output;
}

[[early_fragment_tests]]
fragment half4 fragmentFunc( VertexOutput vert [[stage_in]],
                             texture2d<float, access::sample> u_diffuse_texture [[texture(0)]],
                             sampler u_diffuse_sampler [[sampler(0)]])
{
    float4 resultColor = u_diffuse_texture.sample(u_diffuse_sampler, vert.texcoord);
    resultColor.a *= vert.diffuse.w;
    return static_cast<half4>(resultColor);
}



