#version 450

layout (location = 0) in vec2 v_texcoord;

layout (location = 0) out vec4 outFragColor;

layout (constant_id = 0) const int MAX_TEXTURE_DESCRIPTORS = 16;

layout (set = 0, binding = 0) uniform sampler u_diffuse_sampler;
layout (set = 1, binding = 0) uniform texture2D u_diffuse_texture[MAX_TEXTURE_DESCRIPTORS];

layout (push_constant) uniform PushConstsFs {
    layout(offset = 64) int u_index1;
} pushConstsFs;

const vec3 light01 = vec3( 0.5773502691896258,
                          -0.5773502691895258,
                          -0.5773502691896258 );

const vec3 light02 = vec3( 0.0, 0.0, -1.0 );

void main()
{
    vec3 n = texture(sampler2D(u_diffuse_texture[pushConstsFs.u_index1], u_diffuse_sampler), v_texcoord).xyz * 2.0 - 1.0;

    n.z = min( n.z, 0.6 );
    // 추출한 노멀을 정규화한다.
    n = normalize( n );
    
    // 음영기복도 정의에따라 북서쪽에서 조명으로 음영을 만듬
    // 전체적으로 어두우므로 전체적으로 음영을 0.15만큼 밝게 만들고,
    // 평지( n.z = 1 )인 지역은 0.3, 나머지는 경사도에 따라0.0~0.2999만큼 추가로 올린다.
    float ambient = n.z * n.z * n.z * n.z * 0.3 + 0.2;
    float light01Dot = clamp( dot( -light01, n.xyz ) + ambient, 0.3, 1.0 );
    
    // 등고의 디테일을 위해 0, 0, -1방향으로 음영을 만듬
    float light02Dot = clamp( dot( -light02, n.xyz ), 0.2, 1.0 );
    
    // 두 개를 음영을 반반 섞는다.
    float alpha = clamp( light01Dot * 0.4 + light02Dot * 0.6, 0.55, 1.0 );
    
    outFragColor = vec4( 0.0, 0.0, 0.0, 1.0 - alpha );
}

