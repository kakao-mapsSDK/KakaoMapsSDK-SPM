uniform vec4 u_diffuse_color;

varying vec4 v_diffuse;
varying vec4 v_stroke_diffuse;

varying vec4 v_line_info;   // x : x-direction, 1 : cap( start,end,joint )의 끝쪽
                            // y : y-direction, -1 : down, 0 : center, 1 : up
                            // z : boundary distance field value
                            // w : sdf weight
varying vec4 v_cap_style;   // x : cap/joint style, 0 : round, 1 : square

varying vec4 v_distance;    // x, y: cos(x) at end start joint
                            // z: local percentage
                            // w: global percentage

void main()
{
    float weight = abs( v_line_info.y );
    weight = ( 1.0 - v_cap_style.x ) * length( vec2( v_line_info.x, weight ) ) + v_cap_style.x * max( abs(v_line_info.x), weight );

    float alpha = 1.0 - smoothstep( v_line_info.z, v_line_info.z + v_line_info.w, weight );
    float stroke_alpha = 1.0 - smoothstep( v_cap_style.y, v_cap_style.y + v_line_info.w, weight );

    float is_joint = ceil( v_cap_style.z );
    float dist = v_distance.z * v_cap_style.w + v_line_info.x * (v_distance.z * 2.0 - 1.0) * is_joint;

    float start_threshold = clamp( v_distance.w, 0.0, 1.0 ) * v_cap_style.w;
    start_threshold = start_threshold - v_line_info.y * v_distance.y;

    float end = step( dist, v_cap_style.w + ( v_line_info.y * v_distance.x ) );
    float start = step( start_threshold, dist );

    float not_animated = step( v_distance.w, 0.0 );
    float aa = mix( smoothstep( start_threshold, start_threshold + v_line_info.w, dist ), 1.0, not_animated );
    float anim_alpha = end * start * aa;

    vec4 body_color = v_diffuse.rgba;
    vec4 stroke_color = vec4( v_stroke_diffuse.rgb, v_stroke_diffuse.a * stroke_alpha );
    vec4 mixed = mix( stroke_color, body_color, alpha );

    gl_FragColor = vec4( mixed.rgb, mixed.a * u_diffuse_color.a * anim_alpha );

}
