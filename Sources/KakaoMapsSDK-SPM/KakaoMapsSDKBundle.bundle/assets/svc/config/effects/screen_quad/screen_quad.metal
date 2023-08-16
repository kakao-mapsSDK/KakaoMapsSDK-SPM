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

vertex VertexOutput vertexFunc( const device Vertex *vertexIn [[buffer(0)]],
                                ushort vid [[vertex_id]] )
{
    VertexOutput output;
    
    output.texcoord = vertexIn[vid].a_uv;
    
    output.position = float4(vertexIn[vid].a_position, 1.0);
    output.position.z = (output.position.z + output.position.w) / 2.0;
    
    return output;
}

[[early_fragment_tests]]
fragment half4 fragmentFunc( VertexOutput vert [[stage_in]],
                             texture2d<float, access::sample> u_screen_texture [[texture(0)]],
                             sampler u_screen_sampler [[sampler(0)]])
{
    float4 resultColor = u_screen_texture.sample(u_screen_sampler, vert.texcoord);
    return static_cast<half4>(resultColor);
}


