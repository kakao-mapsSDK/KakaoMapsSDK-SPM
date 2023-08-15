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

struct FragmentUniforms
{
    float4 u_value;
};

struct StencilClearFragmentOut
{
    float depth [[depth(any)]];
//    uint stencil [[stencil]];
};

vertex VertexOutput vertexFunc( const device Vertex *vertexIn [[buffer(0)]] )
{
    VertexOutput output;
    
    output.position = float4(vertexIn->a_position, 0.5, 1.0);
    return output;
}

fragment StencilClearFragmentOut fragmentFunc( VertexOutput vert [[stage_in]],
                                               constant FragmentUniforms &constUniforms [[buffer(0)]] )
{
    StencilClearFragmentOut out;
    out.depth = constUniforms.u_value.x;
    return output;
}



