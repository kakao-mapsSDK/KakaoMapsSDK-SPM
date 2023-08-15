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

constant float3 light01 = float3( 0.5773502691896258,
                                 -0.5773502691895258,
                                 -0.5773502691896258 );

constant float3 light02 = float3( 0.0, 0.0, -1.0 );

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
    float3 n = u_diffuse_texture.sample(u_diffuse_sampler, vert.texcoord).xyz * 2.0 - 1.0;

    // 추출한 노멀을 정규화한다.
    n = normalize( n );
    
    // 음영기복도 정의에따라 북서쪽에서 조명으로 음영을 만듬
    // 전체적으로 어두우므로 전체적으로 음영을 0.2만큼 밝게 만들고,
    // 평지( n.z = 1 )인 지역은 0.3, 나머지는 경사도에 따라0.0~0.2999만큼 추가로 올린다.
    float ambient = n.z * n.z * 0.3 + 0.2;
    float light01Dot = clamp( dot( -light01, n.xyz ) + ambient, 0.0, 1.0 );
    
    // 등고의 디테일을 위해 0, 0, -1방향으로 음영을 만듬
    float light02Dot = clamp( dot( -light02, n.xyz ), 0.0, 1.0 );
    
    // 두 개를 음영을 반반 섞는다.
    float alpha = light01Dot * 0.5 + light02Dot * 0.5;

    float4 outFragColor = float4( 0.0, 0.0, 0.0, 1.0 - alpha );

    return static_cast<half4>(outFragColor);
}



