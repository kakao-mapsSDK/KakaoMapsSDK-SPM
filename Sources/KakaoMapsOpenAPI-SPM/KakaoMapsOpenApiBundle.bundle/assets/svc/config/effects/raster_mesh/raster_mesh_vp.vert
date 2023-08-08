#version 450

layout (location = 0) in ivec4 a_position_s;
layout (location = 1) in ivec2 a_uv_s;

//layout (location = 0) out vec4 v_position;
layout (location = 0) out vec2 v_texcoord;

layout (push_constant) uniform PushConsts {
    mat4 u_mvp;
} pushConsts;

const float int16_scale = 0.00006103515625;

void main()
{
    v_texcoord = a_uv_s * int16_scale;
    vec4 position = vec4( a_position_s.x, a_position_s.y, a_position_s.z + a_position_s.w, 1.0 );
    gl_Position = pushConsts.u_mvp * position;
    gl_Position.z = (gl_Position.z + gl_Position.w) / 2.0;
}
