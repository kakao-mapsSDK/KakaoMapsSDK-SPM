#include <metal_stdlib>
#include <metal_texture>

using namespace metal;

constant float int16_scale = 0.00006103515625;

struct __attribute((packed)) Vertex
{
    packed_float4 a_position;
    packed_short2 a_uv;
};

struct VertexOutput
{
    float4 position [[position]];
    float4 diffuse;
};

struct VertexUniforms
{
    float4 u_view_level;
    float4 u_view_scale;
};

struct VertexInstanceUniforms
{
    float4 u_palette_info;
    float4x4 u_mvp;
};

vertex VertexOutput vertexFunc( const device Vertex *vertexIn [[buffer(0)]],
                                constant VertexUniforms &constUniforms [[buffer(1)]],
                                constant VertexInstanceUniforms &instanceUniforms [[buffer(2)]],
                                texture2d<float, access::sample> u_diffuse_texture [[texture(0)]],
                                sampler u_diffuse_sampler [[sampler(0)]],
                                ushort vid [[vertex_id]] )
{
    VertexOutput output;
    float2 _uv = float2(vertexIn[vid].a_uv) * int16_scale;
    float lv = constUniforms.u_view_level.x * instanceUniforms.u_palette_info.x;
    float2 uv = float2( _uv.x + lv, _uv.y + instanceUniforms.u_palette_info.y );
    output.diffuse = u_diffuse_texture.sample(u_diffuse_sampler, uv);
    
    output.position = instanceUniforms.u_mvp * float4( vertexIn[vid].a_position.x, vertexIn[vid].a_position.y, vertexIn[vid].a_position.z * constUniforms.u_view_scale.z, 1.0 );
    output.position.z = (output.position.z + output.position.w) / 2.0;
    
    return output;
}

[[early_fragment_tests]]
fragment half4 fragmentFunc( VertexOutput vert [[stage_in]] )
{
    return static_cast<half4>(vert.diffuse);
}



