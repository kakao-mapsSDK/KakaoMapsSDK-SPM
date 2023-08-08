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
    float4 u_clearColor;
};

vertex VertexOutput vertexFunc( const device Vertex *vertexIn [[buffer(0)]],
                               ushort vid [[vertex_id]] )
{
    VertexOutput output;
    
    output.position = float4(vertexIn[vid].a_position, 0.5, 1.0);
    return output;
}

fragment half4 fragmentFunc( VertexOutput vert [[stage_in]],
                            constant FragmentUniforms &constUniforms [[buffer(0)]] )
{
//    StencilClearFragmentOut out;
//    out.stencil = constUniforms.u_index_vec.x;
    return static_cast<half4>(constUniforms.u_clearColor);
}



