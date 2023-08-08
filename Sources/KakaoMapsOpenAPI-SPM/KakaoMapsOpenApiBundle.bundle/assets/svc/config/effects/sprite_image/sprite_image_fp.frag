#version 450

layout (location = 0) in vec2 v_texcoord;
layout (location = 1) in vec4 v_diffuse;

layout (location = 0) out vec4 outFragColor;

layout (constant_id = 0) const int MAX_TEXTURE_DESCRIPTORS = 16;

layout (set = 2, binding = 0) uniform sampler u_diffuse_sampler;
layout (set = 3, binding = 0) uniform texture2D u_diffuse_texture[MAX_TEXTURE_DESCRIPTORS];

layout (std140, push_constant) uniform PushConstsFs {
    layout(offset = 80) int u_index1;
} pushConstsFs;

void main()
{
    vec4 resultColor = texture(sampler2D(u_diffuse_texture[pushConstsFs.u_index1], u_diffuse_sampler), v_texcoord);
    resultColor.a *= v_diffuse.w;
    
    outFragColor = resultColor;
}
