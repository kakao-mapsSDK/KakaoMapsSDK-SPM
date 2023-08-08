#version 450

layout (constant_id = 0) const int MAX_TEXTURE_DESCRIPTORS = 16;

layout (location = 0) in vec4 a_position;
layout (location = 1) in ivec2 a_uv_s;

layout (location = 0) out vec4 v_diffuse;

layout (set = 0, binding = 0) uniform sampler u_diffuse_sampler;
layout (set = 1, binding = 0) uniform texture2D u_diffuse_texture[MAX_TEXTURE_DESCRIPTORS];

layout (set = 2, binding = 0) uniform VsDynamic {
    vec4 u_palette_info;
} vsDynamic;

layout (set = 3, binding = 0) uniform VsConst {
    vec4 u_view_level;
    vec4 u_view_scale;
} vsConst;

layout (push_constant) uniform PushConsts {
    mat4 u_mvp;
    ivec4 u_index_vec;
} pushConsts;

const float int16_scale = 0.00006103515625;

void main()
{
    vec2 _uv = a_uv_s * int16_scale;
    float lv = vsConst.u_view_level.x * vsDynamic.u_palette_info.x;
    vec2 uv = vec2( _uv.x + lv, _uv.y + vsDynamic.u_palette_info.y );
    v_diffuse = texture(sampler2D(u_diffuse_texture[pushConsts.u_index_vec.x], u_diffuse_sampler), uv);
    
    gl_Position = pushConsts.u_mvp * vec4( a_position.x, a_position.y, a_position.z * vsConst.u_view_scale.z, 1.0 );
    gl_Position.z = (gl_Position.z + gl_Position.w) / 2.0;
}
