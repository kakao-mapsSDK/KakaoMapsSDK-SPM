#version 450

//attribute
layout (location = 0) in vec4 a_position;
layout (location = 1) in uvec4 a_color_b;

//varying
layout (location = 0) out vec2 v_texcoord;
layout (location = 1) out vec4 v_diffuse;

//uniform
layout (push_constant) uniform PushConsts {
    vec4 u_viewport;
} pushConsts;

float inverseWeight = 1.0/255.0;

void main()
{
    v_texcoord = a_position.zw;
    v_diffuse = a_color_b * inverseWeight;
    
    gl_Position.x = a_position.x * 2.0 / pushConsts.u_viewport.z - 1.0;
    gl_Position.y = (1.0 - a_position.y / pushConsts.u_viewport.w) * 2.0 - 1.0;
    gl_Position.z = 0.0;
    gl_Position.w = 1.0;
    
    gl_Position.z = (gl_Position.z + gl_Position.w) / 2.0;
}
