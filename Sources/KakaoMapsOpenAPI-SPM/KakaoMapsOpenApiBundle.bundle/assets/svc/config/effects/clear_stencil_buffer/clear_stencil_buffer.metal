#include <metal_stdlib>
#include <metal_texture>

using namespace metal;

struct __attribute((packed)) Vertex
{
    packed_float2 a_position;
};

struct VertexOutput
{
    float4 position [[position]];
};

//struct FragmentUniforms
//{
//    float4 u_index_vec;
//};

//struct StencilClearFragmentOut
//{
//    float depth [[depth(any)]];
//};

vertex VertexOutput vertexFunc( const device Vertex *vertexIn [[buffer(0)]] )
{
    VertexOutput output;
    
    output.position = float4(vertexIn->a_position, 0.5, 1.0);
    return output;
}

fragment half4 fragmentFunc( VertexOutput vert [[stage_in]] )
{
//    StencilClearFragmentOut out;
//    out.stencil = constUniforms.u_index_vec.x;
    return half4(0.0, 0.0, 0.0, 0.0);
}



