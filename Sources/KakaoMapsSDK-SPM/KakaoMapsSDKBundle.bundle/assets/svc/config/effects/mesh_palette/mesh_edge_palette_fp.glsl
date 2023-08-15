uniform sampler2D u_diffuse_texture;

varying vec2 v_texcoord;
varying vec4 v_diffuse;
void main()
{
    vec4 diffuseColor = texture2D( u_diffuse_texture, v_texcoord );
    
    gl_FragColor = diffuseColor * v_diffuse;

}
