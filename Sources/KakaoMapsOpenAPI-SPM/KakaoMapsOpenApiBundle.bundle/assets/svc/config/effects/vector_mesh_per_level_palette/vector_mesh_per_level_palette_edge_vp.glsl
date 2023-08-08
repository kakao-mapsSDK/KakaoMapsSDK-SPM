attribute vec4 a_position;
attribute vec2 a_uv;

varying vec4 v_diffuse;

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

const float int16_scale = 0.00006103515625;

void main()
{
    vec2 _uv = a_uv * int16_scale;
    float level = u_view_level.x * u_palette_info.x;
    vec2 uv = vec2( _uv.x + level, _uv.y + u_palette_info.y );
    v_diffuse = texture2D( u_diffuse_texture, uv );
    
    gl_Position = u_mvp * vec4( a_position.x, a_position.y, a_position.z * u_view_scale.z, 1.0 );
}
