#version 450

layout (location = 0) in ivec4 a_position_s;
layout (location = 1) in ivec4 a_normal_b;

layout (location = 0) out vec2 v_texcoord;
layout (location = 1) out vec4 v_diffuse;

layout (push_constant) uniform PushConsts {
    mat4 u_mvp;
    vec4 u_view_scale;
} pushConsts;

const vec3 lightDirection01 = vec3( 0, 0, 1 );
const vec3 lightDirection02 = vec3( 0, -1, 0 );
const vec3 lightDirection03 = vec3( 0.5773502691896258, 0.5773502691895258, 0.5773502691896258 );

const float nWeight = 1.0 / 127.0;
const float uvWeight = 1.0 / 256.0;

void main()
{
    float underShading = min( 1.0, smoothstep( 0.0, 4.0, a_position_s.z ) + 0.93 );
    
    vec3 n = vec3( a_normal_b.x, a_normal_b.y, a_normal_b.z ) * nWeight;
    v_texcoord.x = ( a_normal_b.w + 128.5 ) * uvWeight;
    v_texcoord.y = 0.25;
    
    float light01Dot = dot( lightDirection01, n.xyz );
    float light02Dot = dot( lightDirection02, n.xyz );
    float light03Dot = dot( lightDirection03, n.xyz );
    
    light01Dot = ( light01Dot + 1.0 ) * 0.5;
    light02Dot = ( light02Dot + 1.0 ) * 0.5;
    light03Dot = ( light03Dot + 1.0 ) * 0.5;
    float color = smoothstep( 0.0, 1.0,light01Dot * 0.6 + light02Dot * 0.35 + light03Dot * 0.25 + 0.3 );
    v_diffuse = vec4( color * underShading, color * underShading, color * underShading, 1.0 );
    
    gl_Position = pushConsts.u_mvp * vec4( a_position_s.x, a_position_s.y, a_position_s.z * pushConsts.u_view_scale.z, 1.0 );
    
    gl_Position.z = (gl_Position.z + gl_Position.w) / 2.0;
}
