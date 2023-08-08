#version 450

layout (location = 0) in vec2 v_texcoord;

layout (location = 0) out vec4 outFragColor;

layout (constant_id = 0) const int MAX_TEXTURE_DESCRIPTORS = 16;

layout (set = 0, binding = 0) uniform sampler u_diffuse_sampler;
layout (set = 1, binding = 0) uniform texture2D u_diffuse_texture[MAX_TEXTURE_DESCRIPTORS];

layout (push_constant) uniform PushConstsFs {
    layout(offset = 64) int u_index1;
} pushConstsFs;

void main()
{
    outFragColor = texture(sampler2D(u_diffuse_texture[pushConstsFs.u_index1], u_diffuse_sampler), v_texcoord);
}

