uniform vec4 u_diffuse_color;

varying vec4 v_diffuse;
varying vec4 v_line_info;   // x : x-direction, 1 : cap( start,end,joint )의 끝쪽
                            // y : y-direction, -1 : down, 0 : center, 1 : up
                            // z : boundary distance field value
                            // w : sdf weight
varying vec4 v_cap_style;   // x : cap/joint style, 0 : round, 1 : square

void main()
{
    
    float weight = abs( v_line_info.y );
    weight = ( 1.0 - v_cap_style.x ) * length( vec2( v_line_info.x, weight ) )
           + v_cap_style.x * max( v_line_info.x, weight );
    float alpha = 1.0 - smoothstep( v_line_info.z, v_line_info.w, weight );
    gl_FragColor = vec4( v_diffuse.rgb, alpha * v_diffuse.a * u_diffuse_color.a );

}
