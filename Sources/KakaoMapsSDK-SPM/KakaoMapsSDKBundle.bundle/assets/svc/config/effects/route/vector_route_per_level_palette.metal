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
    packed_float2 a_percent;    // x, y: end / start percentage
    packed_float2 a_curve;      // x, y: cos(x) at end start joint
    packed_char4  a_flag;       // x: joint flag (0 : cap, 1: conneted joint)
    packed_char4  a_joint;
};

struct VertexOutput
{
    float4 position [[position]];
    float4 diffuse;
    float4 stroke_diffuse;
    float4 line_info;
    float4 cap_style;   // x : cap/joint style, 0 : round, 1 : square  / w: local distance
    float4 distance;    // x, y: cos(x) at end start joint
                        // z: local percentage
                        // w: global percentage
};

struct VertexUniforms
{
    float4 u_view_info;
    float4 u_view_level;
};

struct VertexInstanceUniforms
{
    float4 u_scale;
    float4 u_palette_info; // xy: uv, z: progress
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
//    float value_body_or_storke = ( 1.0 - vertexIn[vid].a_flag.x ) * instanceUniforms.u_palette_info.y;
    
    float2 uv = float2( _uv.x + value_between_levels, _uv.y);
    float2 stroke_uv = float2( uv.x, uv.y + instanceUniforms.u_palette_info.y );
    
    output.diffuse = u_diffuse_texture.sample(u_diffuse_sampler, uv);
    output.stroke_diffuse = u_diffuse_texture.sample(u_diffuse_sampler, stroke_uv);

    // 스타일 팔레트에서 현재 카메라 z위치에 맞게 보간된, 라인 body 또는 stroke의 pixel width와 attribute에 있는 meter width중 큰 값을 가져온다.
    uv.y = _uv.y + 2.0 * instanceUniforms.u_palette_info.y;
    float4 line_info = u_diffuse_texture.sample(u_diffuse_sampler, uv) * 255.0;
    line_info.xy = line_info.xy * constUniforms.u_view_info.y;

    float half_width = max( vertexIn[vid].a_line.z / constUniforms.u_view_info.x, line_info.x * 0.5 );
    float stroke_width = line_info.y;

    float sdf_weight = 1.0 / ( half_width + constUniforms.u_view_info.y );
    // line의 distance필드값을 만든다.
    float2 pos_xy = _position.xy + _normal.xy  * ( ( half_width + constUniforms.u_view_info.y ) * vertexIn[vid].a_line.x * constUniforms.u_view_info.x );

    output.line_info.x = vertexIn[vid].a_flag.w * 0.5;
    output.line_info.y = vertexIn[vid].a_flag.z * 0.5;
    output.line_info.z = max( 0.0, 1.0 - ( stroke_width + constUniforms.u_view_info.y + 0.5 ) * sdf_weight );
    output.line_info.w = sdf_weight * constUniforms.u_view_info.y;

    output.position = instanceUniforms.u_mvp * float4( pos_xy / instanceUniforms.u_scale.xy, vertexIn[vid].a_position.z , 1.0 );
    output.position.z = ( output.position.z + output.position.w ) / 2.0;
    
    output.cap_style.x = vertexIn[vid].a_line.w;
    
    // stroke distance 계산
    output.cap_style.y = max( 0.0, 1.0 - ( constUniforms.u_view_info.y + 0.5 ) * sdf_weight );
    output.cap_style.z = vertexIn[vid].a_flag.x;    // joint flag
    output.cap_style.w = vertexIn[vid].a_line.y / ( constUniforms.u_view_info.x * half_width );
    
    float reversed = 1.0 - step( 0.0, instanceUniforms.u_palette_info.z ); // -값이면 뒤집힘
    float2 curve = mix( vertexIn[vid].a_curve, vertexIn[vid].a_curve.yx, reversed );
    float2 percent = mix( vertexIn[vid].a_percent, 1.0 - vertexIn[vid].a_percent.yx, reversed );
    
    // for route joint & animation
    float is_end = mix( vertexIn[vid].a_joint.z, 1.0 - vertexIn[vid].a_joint.z, reversed );
    float end_is_cap = step( curve.x, -1.0 );
    float start_is_cap = step( curve.y, -1.0 );
    curve = float2( mix( curve.x, 1.0, end_is_cap ), mix( curve.y, 1.0, start_is_cap ) );

    output.cap_style.w = output.cap_style.w + ( start_is_cap + end_is_cap );
    
    float cap_percent = ( 1.0 / output.cap_style.w );
    float cap_offset = mix( cap_percent * start_is_cap, -cap_percent * end_is_cap, is_end ) * ( 1.0 - output.line_info.x );
    
    // tan(0.5x) 계산
    float end = sqrt( max( 0.0, ( 1.0 - curve.x ) / ( 1.0 + curve.x ) ) );
    float start = sqrt( max( 0.0, ( 1.0 - curve.y ) / ( 1.0 + curve.y ) ) );
    
    float offset = percent.x - percent.y;
    float threshold = ( abs(instanceUniforms.u_palette_info.z) - percent.y ) / offset;
    
    float2 cw = float2(vertexIn[vid].a_joint.xy);
    cw = mix( cw, cw.yx, reversed );
    float th = clamp( threshold, 0.0, 1.0 ) ;
    float end_grad = max( end - ( output.cap_style.w - th * output.cap_style.w ), 0.0 ) * cw.x;
    float start_grad = max( start - th * output.cap_style.w, 0.0 ) * cw.y;
    float short_grad = mix( start * cw.y, -end * cw.x, th );
    float is_short = step( 0.0, end + start - output.cap_style.w);
    
    output.distance.x = end * cw.x; // tan(0.5x) at end joint
    output.distance.y = mix( start_grad - end_grad, short_grad, is_short ); // tan(0.5x) at start joint
    output.distance.z = is_end + cap_offset; // local percent (0.0 ~ 1.0)
    output.distance.w = threshold;   // local threshold
    
    return output;
}

[[early_fragment_tests]]
fragment half4 fragmentFunc( VertexOutput vert [[stage_in]],
                             constant FragmentInstanceUniforms &instanceUniforms [[buffer(0)]] )
{
    float weight = abs( vert.line_info.y );
    weight = ( 1.0 - vert.cap_style.x ) * length( float2( vert.line_info.x, weight ) ) + vert.cap_style.x * max( abs(vert.line_info.x), weight );
           
    float alpha = 1.0 - smoothstep( vert.line_info.z, vert.line_info.z + vert.line_info.w, weight );
    float stroke_alpha = 1.0 - smoothstep( vert.cap_style.y, vert.cap_style.y + vert.line_info.w, weight );
    
    float is_joint = ceil( vert.cap_style.z );
    float dist = vert.distance.z * vert.cap_style.w + vert.line_info.x * (vert.distance.z * 2.0 - 1.0) * is_joint;
    
//    float grad_length = instanceUniforms.u_route_info.x;
    float start_threshold = clamp( vert.distance.w, 0.0, 1.0 ) * vert.cap_style.w;
    start_threshold = start_threshold - vert.line_info.y * vert.distance.y;
    
    float end = step( dist, vert.cap_style.w + ( vert.line_info.y * vert.distance.x ) );
    float start = step( start_threshold, dist );
    
    float not_animated = step( vert.distance.w, 0.0 );
    float aa = mix( smoothstep( start_threshold, start_threshold + vert.line_info.w, dist ), 1.0, not_animated );
    float anim_alpha = end * start * aa;

    float4 body_color = vert.diffuse.rgba;
    float4 stroke_color = float4( vert.stroke_diffuse.rgb, vert.stroke_diffuse.a * stroke_alpha );
    float4 mixed = mix(stroke_color, body_color, alpha);

    float4 outFragColor = float4( mixed.rgb, mixed.a * instanceUniforms.u_diffuse_color.a * anim_alpha );
    
     return static_cast<half4>(outFragColor);
}



