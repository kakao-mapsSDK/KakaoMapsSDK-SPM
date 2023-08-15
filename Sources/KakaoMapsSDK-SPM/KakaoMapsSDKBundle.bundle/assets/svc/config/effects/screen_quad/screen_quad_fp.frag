#version 450

layout (location = 0) in vec2 v_texcoord;

layout (location = 0) out vec4 outFragColor;

layout (set = 0, binding = 0) uniform sampler u_screen_sampler;
layout (set = 1, binding = 0) uniform texture2D u_screen_texture;

void main()
{
    vec4 resultColor = texture(sampler2D(u_screen_texture, u_screen_sampler), v_texcoord);
    
    outFragColor = resultColor;
}
