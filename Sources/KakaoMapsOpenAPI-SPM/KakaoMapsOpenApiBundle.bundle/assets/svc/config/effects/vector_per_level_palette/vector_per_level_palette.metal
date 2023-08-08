#include <metal_stdlib>
#include <metal_texture>

using namespace metal;

constant float int16_scale = 0.00006103515625;

struct __attribute((packed)) Vertex
{
    packed_float4 a_position;
    packed_short2 a_normal;
    packed_short2 a_uv;
    packed_float4 a_line;
    packed_char4 a_flag;
};

struct VertexOutput
{
    float4 position [[position]];
    float4 diffuse;
    float4 line_info;
    float4 cap_style;   // x : cap/joint style, 0 : round, 1 : square
};

struct VertexUniforms
{
    float4 u_view_info;
    float4 u_view_level;
};

struct VertexInstanceUniforms
{
    float4 u_scale;
    float4 u_palette_info;
    float4x4 u_mvp;
};

struct FragmentInstanceUniforms
{
    float4 u_diffuse_color;
};

vertex VertexOutput vertexFunc( const device Vertex *vertexIn [[buffer(0)]],
                                constant VertexUniforms &constUniforms [[buffer(1)]],
                                constant VertexInstanceUniforms &instanceUniforms [[buffer(2)]],
                                texture2d<float, access::sample> u_diffuse_texture [[texture(0)]],
                                sampler u_diffuse_sampler [[sampler(0)]],
                                ushort vid [[vertex_id]] )
{
    VertexOutput output;
    
    float4 _position = vertexIn[vid].a_position * float4( instanceUniforms.u_scale.xyz, 1.0 );
    float2 _normal = float2(vertexIn[vid].a_normal) * int16_scale;
    float2 _uv = float2(vertexIn[vid].a_uv) * int16_scale;

    // 스타일 팔레트에서 현재 카메라 z위치에 맞게 보간된, 라인 body 또는 stroke의 컬러값을 가져온다.
    float value_between_levels = ( vertexIn[vid].a_flag.y * constUniforms.u_view_level.x + ( 1.0 - vertexIn[vid].a_flag.y ) * constUniforms.u_view_level.y ) * instanceUniforms.u_palette_info.x;
    float value_body_or_storke = ( 1.0 - vertexIn[vid].a_flag.x ) * instanceUniforms.u_palette_info.y;
    float2 uv = float2( _uv.x + value_between_levels, _uv.y + value_body_or_storke );
    output.diffuse = u_diffuse_texture.sample(u_diffuse_sampler, uv);

    // 스타일 팔레트에서 현재 카메라 z위치에 맞게 보간된, 라인 body 또는 stroke의 pixel width와 attribute에 있는 meter width중 큰 값을 가져온다.
    uv.y = _uv.y + 2.0 * instanceUniforms.u_palette_info.y;
    float4 line_info = u_diffuse_texture.sample(u_diffuse_sampler, uv) * 255.0;
    line_info.xy = line_info.xy * constUniforms.u_view_info.y;

    float half_width = max( vertexIn[vid].a_line.z / constUniforms.u_view_info.x, line_info.x * 0.5 );
    float stroke_width = ( line_info.y * vertexIn[vid].a_flag.x );


    float sdf_weight = 1.0 / ( half_width + constUniforms.u_view_info.y );
    // line의 distance필드값을 만든다.
    float2 pos_xy = _position.xy + _normal.xy  * ( ( half_width + constUniforms.u_view_info.y ) * vertexIn[vid].a_line.x * constUniforms.u_view_info.x );

    output.line_info.x = vertexIn[vid].a_flag.w * 0.5;
    output.line_info.y = vertexIn[vid].a_flag.z * 0.5;
    output.line_info.z = max( 0.0, 1.0 - ( stroke_width + constUniforms.u_view_info.y + 0.5 ) * sdf_weight );
    output.line_info.w = output.line_info.z + sdf_weight * constUniforms.u_view_info.y;

    output.position = instanceUniforms.u_mvp * float4( pos_xy / instanceUniforms.u_scale.xy, vertexIn[vid].a_position.z , 1.0 );
    output.position.z = ( output.position.z + output.position.w ) / 2.0;
    
    output.cap_style.x = vertexIn[vid].a_line.w;
    
    return output;
}

[[early_fragment_tests]]
fragment half4 fragmentFunc( VertexOutput vert [[stage_in]],
                             constant FragmentInstanceUniforms &instanceUniforms [[buffer(0)]] )
{
    float weight = abs( vert.line_info.y );
    weight = ( 1.0 - vert.cap_style.x ) * length( float2( vert.line_info.x, weight ) )
           + vert.cap_style.x * max( vert.line_info.x, weight );
           
    float alpha = 1.0 - smoothstep( vert.line_info.z, vert.line_info.w, weight );
    float4 outFragColor = float4( vert.diffuse.rgb, alpha * vert.diffuse.a * instanceUniforms.u_diffuse_color.a );

    return static_cast<half4>(outFragColor);
}



