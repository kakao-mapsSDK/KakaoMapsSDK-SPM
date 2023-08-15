#version 450

layout (location = 0) in vec2 v_texcoord;
layout (location = 1) in vec4 v_diffuse;

layout (location = 0) out vec4 outFragColor;

layout (constant_id = 0) const int MAX_TEXTURE_DESCRIPTORS = 16;

layout (set = 0, binding = 0) uniform sampler u_diffuse_sampler;
layout (set = 1, binding = 0) uniform texture2D u_diffuse_texture[MAX_TEXTURE_DESCRIPTORS];

layout (std140, push_constant) uniform PushConstsFs {
    layout(offset = 16) vec4 u_dimmed_color;
    int u_index1;
} pushConstsFs;

void main()
{
    vec4 diffuseColor = texture(sampler2D(u_diffuse_texture[pushConstsFs.u_index1], u_diffuse_sampler), v_texcoord);
    
    float alpha = pushConstsFs.u_dimmed_color.w * v_diffuse.x;
    vec3 dimmed_color = vec3( pushConstsFs.u_dimmed_color.x * alpha,
                              pushConstsFs.u_dimmed_color.y * alpha,
                              pushConstsFs.u_dimmed_color.z * alpha );
    alpha = 1.0 - alpha;
    
    vec3 color = vec3( diffuseColor.x * alpha,
                      diffuseColor.y * alpha,
                      diffuseColor.z * alpha );
    outFragColor = vec4( color + dimmed_color, v_diffuse.w * diffuseColor.w );
}
