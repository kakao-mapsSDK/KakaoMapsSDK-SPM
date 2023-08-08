uniform sampler2D u_diffuse_texture;
uniform vec4 u_dimmed_color;

varying vec2 v_texcoord;
varying vec4 v_diffuse;

void main()
{
    
    vec4 diffuseColor = texture2D( u_diffuse_texture, v_texcoord );
    float alpha = u_dimmed_color.w * v_diffuse.x;
    vec3 dimmed_color = vec3( u_dimmed_color.x * alpha,
                              u_dimmed_color.y * alpha,
                              u_dimmed_color.z * alpha );
    alpha = 1.0 - alpha;
    
    vec3 color = vec3( diffuseColor.x * alpha,
                       diffuseColor.y * alpha,
                       diffuseColor.z * alpha );
    gl_FragColor = vec4( color + dimmed_color, v_diffuse.w * diffuseColor.w );
}
