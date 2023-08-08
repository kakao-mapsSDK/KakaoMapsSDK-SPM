#include <metal_stdlib>
#include <metal_texture>

using namespace metal;

struct __attribute((packed)) Vertex
{
    packed_short4 a_position;
    packed_short2 a_uv;
};

struct VertexOutput
{
    float4 position [[position]];
    float2 texcoord;
};

struct VertexInstanceUniforms
{
    float4x4 u_mvp;
};

constant float int16_scale = 0.00006103515625;

vertex VertexOutput vertexFunc( const device Vertex *vertexIn [[buffer(0)]],
                                constant VertexInstanceUniforms &instanceUniforms [[buffer(1)]],
                                ushort vid [[vertex_id]] )
{
    VertexOutput output;
    
    output.texcoord = float2(vertexIn[vid].a_uv) * int16_scale;
    float4 position = float4( vertexIn[vid].a_position.x, vertexIn[vid].a_position.y, vertexIn[vid].a_position.z + vertexIn[vid].a_position.w, 1.0 );
    output.position = instanceUniforms.u_mvp * position;
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



