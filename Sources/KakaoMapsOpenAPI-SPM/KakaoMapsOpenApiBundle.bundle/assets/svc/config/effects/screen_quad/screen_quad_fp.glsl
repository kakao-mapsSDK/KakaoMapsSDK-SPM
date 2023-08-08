uniform sampler2D u_screen_texture;

varying vec2 v_texcoord;

void main()
{
    vec4 resultColor = texture2D(u_screen_texture, v_texcoord);
    
    gl_FragColor = resultColor;
}
