attribute vec4 a_position;
attribute vec2 a_uv;
varying vec2 v_texcoord;

uniform mat4 u_mvp;
const float int16_scale = 0.00006103515625;
//const float int16_scale = 0.0001220703125;
void main()
{
    v_texcoord = a_uv * int16_scale;
    vec4 position = vec4( a_position.x, a_position.y, a_position.z + a_position.w, 1.0 );
    gl_Position = u_mvp * position;
}
