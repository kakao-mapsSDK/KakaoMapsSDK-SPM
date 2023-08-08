#include <metal_stdlib>
#include <metal_texture>

using namespace metal;

constant float3 lightDirection01 = float3( 0.0, 0.0, 1.0 );
constant float3 lightDirection02 = float3( 0.0, -1.0, 0.0 );
constant float3 lightDirection03 = float3( 0.5773502691896258, 0.5773502691895258, 0.5773502691896258 );
constant float int16_scale = 0.00006103515625;
constant float int8_scale = 0.007874015748031;

struct __attribute((packed)) Vertex
{
    packed_float4 a_position;
    packed_short2 a_uv;
    packed_char4 a_normal;
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
    
    float underShading = min( 1.0, smoothstep( 0.0, 4.0, vertexIn[vid].a_position.z ) + 0.93 );
        
    float3 n = float3( vertexIn[vid].a_normal.xyz ) * int8_scale;
    float light01Dot = dot( lightDirection01, n.xyz );
    float light02Dot = dot( lightDirection02, n.xyz );
    float light03Dot = dot( lightDirection03, n.xyz );
    
    light01Dot = ( light01Dot + 1.0 ) * 0.5;
    light02Dot = ( light02Dot + 1.0 ) * 0.5;
    light03Dot = ( light03Dot + 1.0 ) * 0.5;
    float color = smoothstep( 0.0, 1.0,light01Dot * 0.6 + light02Dot * 0.35 + light03Dot * 0.25 + 0.3 ) * underShading;
    
    float2 _uv = float2(vertexIn[vid].a_uv) * int16_scale;
    float lv = constUniforms.u_view_level.x * instanceUniforms.u_palette_info.x;
    float2 uv = float2( _uv.x + lv, _uv.y );
    output.diffuse = u_diffuse_texture.sample(u_diffuse_sampler, uv);
    output.diffuse = output.diffuse * float4( color, color, color, 1.0 );
    
    output.position = instanceUniforms.u_mvp * float4( vertexIn[vid].a_position.x, vertexIn[vid].a_position.y, vertexIn[vid].a_position.z * constUniforms.u_view_scale.z, 1.0 );
    output.position.z = (output.position.z + output.position.w) / 2.0;
    
    return output;
}

[[early_fragment_tests]]
fragment half4 fragmentFunc( VertexOutput vert [[stage_in]] )
{
    return static_cast<half4>(float4( vert.diffuse.x, vert.diffuse.y, vert.diffuse.z, vert.diffuse.w * 0.5 ));
}



