attribute vec4 a_position;  // x, y : position( x, y )
                            //    z : model height
                            //    w : terrain height

attribute vec2 a_normal;    // x, y : normal,
attribute vec2 a_uv;        // x, y : diffuse texture uv for line body,

attribute vec4 a_line;      //    x : cap scale
                            //    y : distance ( meter )
                            //    z : min width( meter )
                            //    w : cap/joint style, 0 : round, 1 : square

attribute vec2 a_percent;   // x, y: end / start percentage
attribute vec2 a_curve;     // x, y: cos(x) at end start joint

attribute vec4 a_flag;      //    x : joint flag (0 : cap, 1: conneted joint)
                           //    y : dash type, 0 : no-dash, 1: dash
                           //    z : y-direction, -1 : down, 0 : center, 1 : up
                           //    w : x-direction, 1 : cap( start,end,joint )의 끝쪽
attribute vec4 a_joint;


uniform sampler2D u_diffuse_texture;

uniform mat4 u_mvp;
uniform vec4 u_scale;
uniform vec4 u_palette_info;    // x, y : per pixel uv of an atlas( pallete ) texture
                                // z : progress (percent)



uniform vec4 u_view_info;   // x : distance per unit pixel
                            // y : display scale
                            // x : distance unit pixel per level

uniform vec4 u_view_level;  // x : view( map ) level ( int )
                            // y : view level ( flaot )
                            // z : pixel weight per int level

varying vec4 v_diffuse;
varying vec4 v_stroke_diffuse;

varying vec4 v_line_info;   // x : x-direction, 1 : cap( start,end,joint )의 끝쪽
                            // y : y-direction, -1 : down, 0 : center, 1 : up
                            // z : boundary distance field value
                            // w : sdf weight
varying vec4 v_cap_style;   // x : cap/joint style, 0 : round, 1 : square
varying vec4 v_distance;    // x, y: cos(x) at end start joint
                            // z: local percentage
                            // w: global percentage

const float int16_scale = 0.00006103515625;

void main()
{
    vec4 _position = a_position * vec4( u_scale.xyz, 1.0 );
    vec2 _normal = a_normal * int16_scale;
    vec2 _uv = a_uv * int16_scale;

    // 스타일 팔레트에서 현재 카메라 z위치에 맞게 보간된, 라인 body 또는 stroke의 컬러값을 가져온다.
    float value_between_levels = ( a_flag.y * u_view_level.x + ( 1.0 - a_flag.y ) * u_view_level.y ) * u_palette_info.x;
//    float value_body_or_storke = ( 1.0 - a_flag.x ) * u_palette_info.y;
    vec2 uv = vec2( _uv.x + value_between_levels, _uv.y );
    vec2 stroke_uv = vec2( uv.x, uv.y + u_palette_info.y );

    v_diffuse = texture2D( u_diffuse_texture, uv );
    v_stroke_diffuse = texture2D( u_diffuse_texture, stroke_uv );

    // 스타일 팔레트에서 현재 카메라 z위치에 맞게 보간된, 라인 body 또는 stroke의 pixel width와 attribute에 있는 meter width중 큰 값을 가져온다.
    uv.y = _uv.y + 2.0 * u_palette_info.y;
    vec4 line_info = texture2D( u_diffuse_texture, uv ) * 255.0;
    line_info.xy = line_info.xy * u_view_info.y;

    // half_width에는 이미 stroke값이 포함되어 있음
    float half_width = max( a_line.z / u_view_info.x, line_info.x * 0.5 );
    float stroke_width = line_info.y;

    float sdf_weight = 1.0 / ( half_width + u_view_info.y );
    // line의 distance필드값을 만든다.
    vec2 pos_xy = _position.xy + _normal.xy  * ( ( half_width + u_view_info.y ) * a_line.x * u_view_info.x );

    v_line_info.x = a_flag.w * 0.5;
    v_line_info.y = a_flag.z * 0.5;
    v_line_info.z = max( 0.0, 1.0 - ( stroke_width + u_view_info.y + 0.5 ) * sdf_weight );
    v_line_info.w = sdf_weight * u_view_info.y;

    v_cap_style.x = a_line.w;
    v_cap_style.y = max( 0.0, 1.0 - ( u_view_info.y + 0.5 ) * sdf_weight );
    v_cap_style.z = a_flag.x;
    v_cap_style.w = a_line.y / ( u_view_info.x * half_width );

    float reversed = 1.0 - step( 0.0, u_palette_info.z ); // -값이면 뒤집힘
    vec2 curve = mix( a_curve, a_curve.yx, reversed );
    vec2 percent = mix( a_percent, 1.0 - a_percent.yx, reversed );

    // for route joint & animation
    float is_end = mix( a_joint.z, 1.0 - a_joint.z, reversed );
    float end_is_cap = step( curve.x, -0.999999 );
    float start_is_cap = step( curve.y, -0.999999 );
    curve = vec2( mix( curve.x, 1.0, end_is_cap ), mix( curve.y, 1.0, start_is_cap ) );

    v_cap_style.w = v_cap_style.w + ( start_is_cap + end_is_cap );

    float cap_percent = ( 1.0 / v_cap_style.w );
    float cap_offset = mix( cap_percent * start_is_cap, -cap_percent * end_is_cap, is_end ) * ( 1.0 - v_line_info.x );

    // tan(0.5x) 계산
    float end = sqrt( max( 0.0, ( 1.0 - curve.x ) / ( 1.0 + curve.x ) ) );
    float start =  sqrt( max( 0.0, ( 1.0 - curve.y ) / ( 1.0 + curve.y ) ) );

    float offset = percent.x - percent.y;
    float threshold = ( abs(u_palette_info.z) - percent.y ) / offset;

    vec2 cw = vec2( a_joint.xy );
    cw = mix( cw, cw.yx, reversed );

    float th = clamp( threshold, 0.0, 1.0 ) ;
    float end_grad = max( end - ( v_cap_style.w - th * v_cap_style.w ), 0.0 ) * cw.x;
    float start_grad = max( start - th * v_cap_style.w, 0.0 ) * cw.y;
    float short_grad = mix( start * cw.y, -end * cw.x, th );
    float is_short = step( 0.0, end + start - v_cap_style.w);

    v_distance.x = end * cw.x; // tan(0.5x) at end joint
    v_distance.y = mix( start_grad - end_grad, short_grad, is_short ); // tan(0.5x) at start joint
    v_distance.z = is_end + cap_offset; // local percent (0.0 ~ 1.0)
    v_distance.w = threshold;   // local threshold

    gl_Position = u_mvp * vec4( pos_xy / u_scale.xy, a_position.z , 1.0 );
}
