#version 450

layout (location = 0) in vec4 a_position;
layout (location = 1) in vec2 a_uv;

//layout (location = 0) out vec4 v_position;
layout (location = 0) out vec2 v_texcoord;

layout (push_constant) uniform PushConsts {
    mat4 u_pure_m;
} pushConsts;

void main()
{
    v_texcoord = a_uv;
    gl_Position = pushConsts.u_pure_m * vec4( a_position.x, a_position.y, 0.0, 1.0 );
    gl_Position.z = (gl_Position.z + gl_Position.w) / 2.0;
}
