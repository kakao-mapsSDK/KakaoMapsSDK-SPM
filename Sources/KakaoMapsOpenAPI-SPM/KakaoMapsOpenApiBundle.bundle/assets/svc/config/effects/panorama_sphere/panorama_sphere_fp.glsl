uniform sampler2D u_diffuse_texture;

uniform vec4 u_diffuse_color;

varying vec3 v_texcoord;
varying vec2 v_depth;

void main()
{
    vec2 texCoord = vec2(v_texcoord.xy / v_texcoord.z);
    vec4 realColor = texture2D(u_diffuse_texture, texCoord);
    
//    gl_FragColor = realColor * vec4(1.0 - diffuseColor.z);
    gl_FragColor = realColor;
//    gl_FragColor = realColor * vec4(depthVarying.x/depthVarying.y, 0.5, 0.5, 1.0);
    gl_FragColor.a = u_diffuse_color.w * realColor.a;
}

