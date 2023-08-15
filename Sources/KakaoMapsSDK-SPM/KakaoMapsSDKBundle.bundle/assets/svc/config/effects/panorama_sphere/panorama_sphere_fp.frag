#version 450

layout (location = 0) in vec3 v_texcoord;
layout (location = 1) in vec2 v_depth;

layout (location = 0) out vec4 outFragColor;

layout (constant_id = 0) const int MAX_TEXTURE_DESCRIPTORS = 16;

layout (set = 0, binding = 1) uniform sampler u_diffuse_sampler;
layout (set = 1, binding = 1) uniform texture2D u_diffuse_texture[MAX_TEXTURE_DESCRIPTORS];

layout (std140, push_constant) uniform PushConstsFs {
    layout(offset = 80) vec4 u_diffuse_color;
    int u_index2;            
} pushConstsFs;

void main()
{
    vec2 texCoord = vec2(v_texcoord.xy / v_texcoord.z);
    vec4 realColor = texture(sampler2D(u_diffuse_texture[pushConstsFs.u_index2], u_diffuse_sampler), texCoord);
    
//    gl_FragColor = realColor * vec4(1.0 - diffuseColor.z);
//    gl_FragColor = realColor * vec4(depthVarying.x/depthVarying.y, 0.5, 0.5, 1.0);
    outFragColor = realColor;
    outFragColor.a = pushConstsFs.u_diffuse_color.w * outFragColor.a;
}

