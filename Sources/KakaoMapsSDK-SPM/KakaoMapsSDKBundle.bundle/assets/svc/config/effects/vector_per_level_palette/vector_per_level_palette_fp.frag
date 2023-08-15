#version 450

layout (location = 0) in vec4 v_diffuse;
layout (location = 1) in vec4 v_line_info;      // x : boundary distance field value
                                                // y : pixel distance
                                                // z : original period
                                                // w : period with width weight
layout (location = 2) in vec4 v_cap_style;   // x : cap/joint style, 0 : round, 1 : square

layout (push_constant) uniform PushConstsFs {
    layout(offset = 80) int u_index1;
} pushConstsFs;


layout (set = 2, binding = 1) uniform FsDynamic {
    vec4 u_diffuse_color;
} fsDynamic;

layout (location = 0) out vec4 outFragColor;

void main()
{
    float weight = abs( v_line_info.y );
    weight = ( 1.0 - v_cap_style.x ) * length( vec2( v_line_info.x, weight ) )
           + v_cap_style.x * max( v_line_info.x, weight );
    float alpha = 1.0 - smoothstep( v_line_info.z, v_line_info.w, weight );
    outFragColor = vec4( v_diffuse.rgb, alpha * v_diffuse.a * fsDynamic.u_diffuse_color.a );
}
