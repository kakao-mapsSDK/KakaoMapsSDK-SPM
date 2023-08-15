attribute vec4 a_position;
attribute vec2 a_uv;
varying vec2 v_texcoord;

uniform mat4 u_pure_m;

void main()
{
    v_texcoord = a_uv;
    gl_Position = u_pure_m * vec4( a_position.x, a_position.y, 0.0, 1.0 );
}
