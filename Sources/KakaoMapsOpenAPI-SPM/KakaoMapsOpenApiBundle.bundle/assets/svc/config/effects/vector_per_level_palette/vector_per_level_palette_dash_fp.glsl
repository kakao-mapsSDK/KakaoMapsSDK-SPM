uniform sampler2D u_diffuse_texture;

uniform vec4 u_view_info;   // x : distance per unit pixel
                            // y : display scale

uniform vec4 u_palette_info;    // x, y : per pixel uv of an atlas( pallete ) texture
                                //    z : 0 : stroke, 1: line body
uniform vec4 u_diffuse_color;

varying vec4 v_diffuse;
varying vec4 v_line_info;   // x : x-direction, 1 : cap( start,end,joint )의 끝쪽
                            // y : y-direction, -1 : down, 0 : center, 1 : up
                            // z : boundary distance field value
                            // w : sdf weight
                            
varying vec4 v_dash;        // x : dash type, 0 : no-dash, 1: dash
                            // y : dash period ( px )
                            // z : dash/line cap , 0 : round, 1: rect
                            // w : line half width
                            
varying vec4 v_dist;        // x : distance ( px )
                            // y : dash pattern period : period * width( px )
                            // z : dash pattern u( uv ) distance in dash palette
                            // w : starting dash pattern v( uv )


void main()
{
    float dpScale = max( 1.0, u_view_info.y );
    float rest = mod( v_dist.x, v_dist.y ); //distance값을 전체 period*width 값으로 나눈 나머지 값, 0 ~ divide-1
    
    float inverse_dash_period = 1.0 / v_dash.y;
    float section = rest / max( 1.0, v_dash.w * 2.0 ); // 0 ~ period
    float ratio = section * inverse_dash_period; // 0 ~ 1
    
    vec2 uv = vec2( u_palette_info.x + v_dist.z * ratio, v_dist.w );
    vec4 pattern = texture2D( u_diffuse_texture, uv ) * 255.0;
    
    float abs_y = abs( v_line_info.y );
    float weight = ( ( 1.0 - v_dash.z ) * length( vec2( v_line_info.x, abs_y ) ) + v_dash.z * max( v_line_info.x, abs_y ) );
    float alpha = 1.0 - smoothstep( v_line_info.z, v_line_info.z + ( v_line_info.w ) * dpScale, weight );
    
    
    gl_FragColor = vec4( v_diffuse.rgb, alpha * v_diffuse.a * u_diffuse_color.a * pattern.b );

}
