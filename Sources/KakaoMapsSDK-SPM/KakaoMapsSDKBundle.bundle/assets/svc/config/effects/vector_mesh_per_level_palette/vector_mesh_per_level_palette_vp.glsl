attribute vec4 a_position;  // x, y : position( x, y )
                            //    z : model height
                            //    w : terrain height
                            
attribute vec2 a_uv;        // x, y : diffuse texture uv for line body,

attribute vec4 a_normal;    // x, y, z : normal, w : body: 0, storke : 1
//
uniform sampler2D u_diffuse_texture;
uniform mat4 u_mvp;
uniform vec4 u_palette_info;    // x, y : per pixel uv of an atlas( pallete ) texture


                            
uniform vec4 u_view_info;   // x : distance per unit pixel
                            // y : display scale
                            // x : distance unit pixel per level

uniform vec4 u_view_level;  // x : view( map ) level ( int )
                            // y : view level ( flaot )
                            // z : pixel weight per int level
uniform vec4 u_view_scale;

varying vec4 v_diffuse;

const vec3 lightDirection01 = vec3( 0, 0, 1 );
const vec3 lightDirection02 = vec3( 0, -1, 0 );
const vec3 lightDirection03 = vec3( 0.5773502691896258, 0.5773502691895258, 0.5773502691896258 );
//
const float int16_scale = 0.00006103515625;
const float int8_scale = 0.007874015748031;


void main()
{
    
    float underShading = min( 1.0, smoothstep( 0.0, 4.0, a_position.z ) + 0.93 );
    
    vec3 n = vec3( a_normal.x, a_normal.y, a_normal.z ) * int8_scale;
    float light01Dot = dot( lightDirection01, n.xyz );
    float light02Dot = dot( lightDirection02, n.xyz );
    float light03Dot = dot( lightDirection03, n.xyz );
    
    light01Dot = ( light01Dot + 1.0 ) * 0.5;
    light02Dot = ( light02Dot + 1.0 ) * 0.5;
    light03Dot = ( light03Dot + 1.0 ) * 0.5;
    float color = smoothstep( 0.0, 1.0,light01Dot * 0.6 + light02Dot * 0.35 + light03Dot * 0.25 + 0.3 ) * underShading;
    
    vec2 _uv = a_uv * int16_scale;
    float level = u_view_level.x * u_palette_info.x;
    vec2 uv = vec2( _uv.x + level, _uv.y );
    v_diffuse = texture2D( u_diffuse_texture, uv );
    
    
    v_diffuse = v_diffuse * vec4( color, color, color, 1.0 );
    
    gl_Position = u_mvp * vec4( a_position.x, a_position.y, a_position.z * u_view_scale.z, 1.0 );

}
