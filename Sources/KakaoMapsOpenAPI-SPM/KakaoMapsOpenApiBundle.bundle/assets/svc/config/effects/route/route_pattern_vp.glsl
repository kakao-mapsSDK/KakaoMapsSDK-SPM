attribute vec3 a_position;
attribute vec2 a_uv;
varying vec2 v_texcoord;

uniform mat4 u_mvp;


void main()
{
    v_texcoord = a_uv;
    gl_Position = u_mvp * vec4( a_position.x, a_position.y, a_position.z, 1.0 );
}
