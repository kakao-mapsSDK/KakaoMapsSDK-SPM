
varying vec4 v_diffuse;
void main()
{
//    vec4 diffuseColor = texture2D( u_diffuse_texture, v_texcoord );
//    v_diffuse.a *= 0.5;
//    gl_FragColor = diffuseColor * v_diffuse;
    gl_FragColor = vec4( v_diffuse.x, v_diffuse.y, v_diffuse.z, v_diffuse.w * 0.5 );
}
