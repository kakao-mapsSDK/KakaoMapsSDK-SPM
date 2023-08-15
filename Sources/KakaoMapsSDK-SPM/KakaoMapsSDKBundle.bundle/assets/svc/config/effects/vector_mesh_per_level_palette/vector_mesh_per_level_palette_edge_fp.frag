#version 450

layout (location = 0) in vec4 v_diffuse;

layout (location = 0) out vec4 outFragColor;

void main()
{
//    vec4 diffuseColor = texture2D( u_diffuse_texture, v_texcoord );
    
    outFragColor =  v_diffuse;

}
