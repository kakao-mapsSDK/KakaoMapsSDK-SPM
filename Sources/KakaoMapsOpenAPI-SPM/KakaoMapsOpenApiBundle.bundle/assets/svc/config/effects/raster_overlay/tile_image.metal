#include <metal_stdlib>
#include <metal_texture>

using namespace metal;

struct __attribute((packed)) Vertex
{
    packed_float3 a_position;
    packed_float2 a_uv;
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

vertex VertexOutput vertexFunc( const device Vertex *vertexIn [[buffer(0)]],
                                constant VertexInstanceUniforms &instanceUniforms [[buffer(1)]],
                                ushort vid [[vertex_id]] )
{
    VertexOutput output;
    output.texcoord = vertexIn[vid].a_uv;
    output.position = instanceUniforms.u_mvp * float4( vertexIn[vid].a_position, 1.0 );
    output.position.z = (output.position.z + output.position.w) / 2.0;
    
    return output;
}

[[early_fragment_tests]]
fragment half4 fragmentFunc( VertexOutput vert [[stage_in]],
                             texture2d<float, access::sample> u_diffuse_texture [[texture(0)]],
                             sampler u_diffuse_sampler [[sampler(0)]])
{
    float4 outFragColor = u_diffuse_texture.sample(u_diffuse_sampler, vert.texcoord);
    outFragColor.w = 0.2;
    return static_cast<half4>(outFragColor);
}



