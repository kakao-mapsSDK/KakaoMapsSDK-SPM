
#version 450

layout (constant_id = 0) const int MAX_TEXTURE_DESCRIPTORS = 16;

layout (set = 2, binding = 1) uniform FsDynamic {
    vec4 u_palette_info;        // x, y : per pixel uv of an atlas( pallete ) texture
    vec4 u_diffuse_color;
} fsDynamic;

layout (set = 3, binding = 1) uniform FsConst {
    vec4 u_view_info;           // x : distance per unit pixel
// y : display scale
// z : distance unit pixel per level

    vec4 u_view_level;          // x : view( map ) level ( int )
// y : view level ( flaot )
// z : pixel weight per int level
} fsConst;


layout (set = 0, binding = 0) uniform sampler u_diffuse_sampler;
layout (set = 1, binding = 0) uniform texture2D u_diffuse_texture[MAX_TEXTURE_DESCRIPTORS];


layout (push_constant) uniform PushConstsFs {
    layout(offset = 80) int u_index1;
} pushConstsFs;


layout (location = 0) in vec4 v_diffuse;
layout (location = 1) in vec4 v_line_info;
// x : boundary distance field value
// y : y-direction, -1 : down, 0 : center, 1 : up
// z : x-direction, 1 : cap( start,end,joint )의 끝쪽
// w : period with width weight

layout (location = 2) in vec4 v_dash;        // x : dash type, 0 : no-dash, 1: dash
// y : dash period ( px )
// z : dash cap , 0 : round, 1: rect
// w : empty

layout (location = 3) in vec4 v_dist;        // x : distance ( px )
// y : dash pattern period : period * width( px )
// z : dash pattern u( uv ) distance in dash palette
// w : starting dash pattern v( uv )

layout (location = 0) out vec4 outFragColor;


void main()
{
    float rest = mod(v_dist.x, v_dist.y);//distance값을 전체 period*width 값으로 나눈 나머지 값, 0 ~ divide-1
    
    float inverse_dash_period = 1.0 / v_dash.y;
    float section = rest / max(1.0, v_dash.w * 2.0);// 0 ~ period
    float ratio = section / v_dash.y;// 0 ~ 1

    vec2 uv = vec2(fsDynamic.u_palette_info.x + v_dist.z * ratio, v_dist.w);
    vec4 pattern = texture(sampler2D(u_diffuse_texture[pushConstsFs.u_index1], u_diffuse_sampler), uv) * 255.0;

    float abs_y = abs( v_line_info.y );
    float weight = ((1.0 - v_dash.z) * length(vec2(v_line_info.x, abs_y)) + v_dash.z * max(v_line_info.x, abs_y));

    float alpha = 1.0 - smoothstep(
    v_line_info.z, v_line_info.z + v_line_info.w * fsConst.u_view_info.y, weight);
    outFragColor = vec4(v_diffuse.rgb, alpha * v_diffuse.a * fsDynamic.u_diffuse_color.a * pattern.b);

}

