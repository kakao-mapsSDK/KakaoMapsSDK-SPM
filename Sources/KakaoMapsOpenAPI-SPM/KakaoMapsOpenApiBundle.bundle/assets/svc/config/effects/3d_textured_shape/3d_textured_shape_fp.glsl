uniform sampler2D u_diffuse_texture;
varying vec2 v_texcoord;

void main()
{
    gl_FragColor = texture2D( u_diffuse_texture, v_texcoord );
//    if( gl_FragColor.a == 0.0 )
//        discard;
}

