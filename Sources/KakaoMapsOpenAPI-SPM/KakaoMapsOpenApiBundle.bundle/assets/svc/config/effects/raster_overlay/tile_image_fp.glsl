uniform sampler2D u_diffuse_texture;
varying vec2 v_texcoord;

void main()
{
    gl_FragColor = vec4( texture2D( u_diffuse_texture, v_texcoord ).xyz, 0.2 );
//    gl_FragColor = vec4( 0.0, 0.0, 0.0, 0.5 );
}

