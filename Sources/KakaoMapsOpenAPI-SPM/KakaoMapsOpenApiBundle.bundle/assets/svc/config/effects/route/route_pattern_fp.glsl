uniform sampler2D u_diffuse_texture;
uniform vec4 u_diffuse_color;
varying vec2 v_texcoord;


void main()
{
    gl_FragColor = texture2D(u_diffuse_texture, v_texcoord) * u_diffuse_color;
}
