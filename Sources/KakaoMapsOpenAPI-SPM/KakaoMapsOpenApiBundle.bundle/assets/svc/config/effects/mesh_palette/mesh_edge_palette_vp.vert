#version 450

layout (location = 0) in ivec4 a_position_s;
layout (location = 1) in ivec4 a_normal_b;

layout (location = 0) out vec2 v_texcoord;
layout (location = 1) out vec4 v_diffuse;

layout (push_constant) uniform PushConsts {
    mat4 u_mvp;
    vec4 u_view_scale;
} pushConsts;

const float uvWeight = 1.0 / 256.0;

void main()
{
    
    v_texcoord.x = ( a_normal_b.w + 128.5 ) * uvWeight;
    v_texcoord.y = 0.75;
    
    v_diffuse = vec4( 1.0, 1.0, 1.0, 1.0 );
    gl_Position = pushConsts.u_mvp * vec4( a_position_s.x, a_position_s.y, a_position_s.z * pushConsts.u_view_scale.z, 1.0 );
    
    gl_Position.z = (gl_Position.z + gl_Position.w) / 2.0;
}
