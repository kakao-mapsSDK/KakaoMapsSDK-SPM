uniform sampler2D u_diffuse_texture;

varying vec2 v_texcoord;

varying vec4 v_diffuse;

void main()
{
    vec4 resultColor = texture2D(u_diffuse_texture, v_texcoord);
    resultColor.a *= v_diffuse.w;
    
    gl_FragColor = resultColor;
    //gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
