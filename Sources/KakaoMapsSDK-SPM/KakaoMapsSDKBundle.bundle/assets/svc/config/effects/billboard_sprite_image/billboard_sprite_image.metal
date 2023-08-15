#include <metal_stdlib>
#include <metal_texture>

using namespace metal;

constant float int16_scale = 0.00006103515625;

struct __attribute((packed)) Vertex
{
    packed_float4 a_position;
    packed_float4 a_normal;
};

struct VertexOutput
{
    float4 position [[position]];
    float2 texcoord;
};

struct VertexUniforms
{
    float4 u_viewport;
};

struct VertexInstanceUniforms
{
    float4 u_pixel_rotation;
    float4 u_pixel_translation_scale;
    float4 u_pixel_anchor;
    float4x4 u_mvp;
};

float3 rotate_vector( float4 quat, float3 vector )
{
    return vector + 2.0 * cross( cross( vector, quat.xyz ) + quat.w * vector, quat.xyz );
}


vertex VertexOutput vertexFunc( const device Vertex *vertexIn [[buffer(0)]],
                                constant VertexUniforms &constUniforms [[buffer(1)]],
                                constant VertexInstanceUniforms &instanceUniforms [[buffer(2)]],
                                ushort vid [[vertex_id]] )
{
    VertexOutput output;
    
    output.texcoord = vertexIn[vid].a_normal.zw;

    float4 currentPosition = float4( vertexIn[vid].a_position.xyz, 1.0 );
    currentPosition = instanceUniforms.u_mvp * currentPosition;
    currentPosition /= currentPosition.w;
    
    float3 translation = rotate_vector( instanceUniforms.u_pixel_rotation, float3( vertexIn[vid].a_normal.xy, 0.0) );
    translation.xy *= instanceUniforms.u_pixel_translation_scale.zw;
    
    translation += rotate_vector( instanceUniforms.u_pixel_rotation, float3( instanceUniforms.u_pixel_anchor.xy, 0.0 ) );
    
    translation.xy += instanceUniforms.u_pixel_translation_scale.xy;
    
    output.position.x = currentPosition.x + ( (translation.x ) / constUniforms.u_viewport.z ) * 2.0;
    output.position.y = currentPosition.y - ( (translation.y ) / constUniforms.u_viewport.w ) * 2.0;
    output.position.zw = currentPosition.zw;
    
    output.position.z = (output.position.z + output.position.w) / 2.0;
    
    return output;
}

[[early_fragment_tests]]
fragment half4 fragmentFunc( VertexOutput vert [[stage_in]],
                             texture2d<float, access::sample> u_diffuse_texture [[texture(0)]],
                             sampler u_diffuse_sampler [[sampler(0)]])
{
    float4 diffuseColor = u_diffuse_texture.sample(u_diffuse_sampler, vert.texcoord);

    return static_cast<half4>(diffuseColor);
}



