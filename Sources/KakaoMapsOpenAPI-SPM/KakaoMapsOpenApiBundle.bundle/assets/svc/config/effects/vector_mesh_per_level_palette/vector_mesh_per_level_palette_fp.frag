#version 450

layout (location = 0) in vec4 v_diffuse;

layout (location = 0) out vec4 outFragColor;

void main()
{
//    vec4 diffuseColor = texture2D( u_diffuse_texture, v_texcoord );
//    v_diffuse.a *= 0.5;
//    gl_FragColor = diffuseColor * v_diffuse;
    outFragColor = vec4( v_diffuse.x, v_diffuse.y, v_diffuse.z, v_diffuse.w * 0.5 );
}
