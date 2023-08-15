#version 450

layout (location = 0) in vec4 a_position;
layout (location = 1) in ivec2 a_uv_s;
layout (location = 2) in ivec4 a_normal_b;

layout (location = 0) out vec4 v_diffuse;

layout (constant_id = 0) const int MAX_TEXTURE_DESCRIPTORS = 16;

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

const vec3 lightDirection01 = vec3( 0, 0, 1 );
const vec3 lightDirection02 = vec3( 0, -1, 0 );
const vec3 lightDirection03 = vec3( 0.5773502691896258, 0.5773502691895258, 0.5773502691896258 );
//
const float int16_scale = 0.00006103515625;
const float int8_scale = 0.007874015748031;


void main()
{
    
    float underShading = min( 1.0, smoothstep( 0.0, 4.0, a_position.z ) + 0.93 );
    
    vec3 n = vec3( a_normal_b.x, a_normal_b.y, a_normal_b.z ) * int8_scale;
    float light01Dot = dot( lightDirection01, n.xyz );
    float light02Dot = dot( lightDirection02, n.xyz );
    float light03Dot = dot( lightDirection03, n.xyz );
    
    light01Dot = ( light01Dot + 1.0 ) * 0.5;
    light02Dot = ( light02Dot + 1.0 ) * 0.5;
    light03Dot = ( light03Dot + 1.0 ) * 0.5;
    float color = smoothstep( 0.0, 1.0,light01Dot * 0.6 + light02Dot * 0.35 + light03Dot * 0.25 + 0.3 ) * underShading;
    
    vec2 _uv = a_uv_s * int16_scale;
    float lv = vsConst.u_view_level.x * vsDynamic.u_palette_info.x;
    vec2 uv = vec2( _uv.x + lv, _uv.y );
    v_diffuse = texture(sampler2D(u_diffuse_texture[pushConsts.u_index_vec.x], u_diffuse_sampler), uv);
    v_diffuse = v_diffuse * vec4( color, color, color, 1.0 );
    
    gl_Position = pushConsts.u_mvp * vec4( a_position.x, a_position.y, a_position.z * vsConst.u_view_scale.z, 1.0 );
    gl_Position.z = (gl_Position.z + gl_Position.w) / 2.0;
}
