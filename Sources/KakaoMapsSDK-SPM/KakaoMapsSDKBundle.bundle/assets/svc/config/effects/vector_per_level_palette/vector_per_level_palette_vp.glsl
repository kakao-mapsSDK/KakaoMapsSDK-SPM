attribute vec4 a_position;  // x, y : position( x, y )
                            //    z : model height
                            //    w : terrain height
                            
attribute vec2 a_normal;    // x, y : normal, 
attribute vec2 a_uv;        // x, y : diffuse texture uv for line body,
                            
attribute vec4 a_line;      //    x : cap scale
                            //    y : distance ( meter )
                            //    z : min width( meter )
                            //    w : cap/joint style, 0 : round, 1 : square

attribute vec4 a_flag;      //    x : line type, 0 : stroke, 1: line body
                            //    y : dash type, 0 : no-dash, 1: dash
                            //    z : y-direction, -1 : down, 0 : center, 1 : up
                            //    w : x-direction, 1 : cap( start,end,joint )의 끝쪽


uniform sampler2D u_diffuse_texture;

uniform mat4 u_mvp;
uniform vec4 u_scale;
uniform vec4 u_palette_info;    // x, y : per pixel uv of an atlas( pallete ) texture


                            
uniform vec4 u_view_info;   // x : distance per unit pixel 
                            // y : display scale
                            // x : distance unit pixel per level

uniform vec4 u_view_level;  // x : view( map ) level ( int )
                            // y : view level ( flaot )
                            // z : pixel weight per int level

varying vec4 v_diffuse;

varying vec4 v_line_info;   // x : x-direction, 1 : cap( start,end,joint )의 끝쪽
                            // y : y-direction, -1 : down, 0 : center, 1 : up
                            // z : boundary distance field value
                            // w : sdf weight
varying vec4 v_cap_style;   // x : cap/joint style, 0 : round, 1 : square

const float int16_scale = 0.00006103515625;

void main()
{
    vec4 _position = a_position * vec4( u_scale.xyz, 1.0 );
    vec2 _normal = a_normal * int16_scale;
    vec2 _uv = a_uv * int16_scale;
    
    // 스타일 팔레트에서 현재 카메라 z위치에 맞게 보간된, 라인 body 또는 stroke의 컬러값을 가져온다.
    float value_between_levels = ( a_flag.y * u_view_level.x + ( 1.0 - a_flag.y ) * u_view_level.y ) * u_palette_info.x;
    float value_body_or_storke = ( 1.0 - a_flag.x ) * u_palette_info.y;
    vec2 uv = vec2( _uv.x + value_between_levels, _uv.y + value_body_or_storke );
    v_diffuse = texture2D( u_diffuse_texture, uv );
    
    // 스타일 팔레트에서 현재 카메라 z위치에 맞게 보간된, 라인 body 또는 stroke의 pixel width와 attribute에 있는 meter width중 큰 값을 가져온다.
    uv.y = _uv.y + 2.0 * u_palette_info.y;
    vec4 line_info = texture2D( u_diffuse_texture, uv )  * 255.0;
    line_info.xy = line_info.xy * u_view_info.y;
    
    // half_width에는 이미 stroke값이 포함되어 있음
    float half_width = max( a_line.z / u_view_info.x, ( line_info.x ) * 0.5 );
    float stroke_width = ( line_info.y * a_flag.x );
    
    
    float sdf_weight = 1.0 / ( half_width + u_view_info.y );
    // line의 distance필드값을 만든다.
    vec2 pos_xy = _position.xy + _normal.xy  * ( ( half_width + u_view_info.y ) * a_line.x * u_view_info.x );
    
    v_line_info.x = a_flag.w * 0.5;
    v_line_info.y = a_flag.z * 0.5;
    v_line_info.z = max( 0.0, 1.0 - ( stroke_width + u_view_info.y + 0.5 ) * sdf_weight );
    v_line_info.w = v_line_info.z + sdf_weight * u_view_info.y;
    
    v_cap_style.x = a_line.w;
    
    gl_Position = u_mvp * vec4( pos_xy / u_scale.xy, a_position.z , 1.0 );
}
