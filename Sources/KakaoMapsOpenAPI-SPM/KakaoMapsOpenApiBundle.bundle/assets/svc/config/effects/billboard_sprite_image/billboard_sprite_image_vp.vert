#version 450

layout (location = 0) in vec4 a_position;
layout (location = 1) in vec4 a_normal;

layout (location = 0) out vec2 v_texcoord;

layout (set = 0, binding = 0) uniform VsConst {
    vec4 u_viewport;
} vsConst;

layout (set = 1, binding = 0) uniform VsDynamic {
    vec4 u_pixel_rotation;
    vec4 u_pixel_translation_scale;
    vec4 u_pixel_anchor;
} vsDynamic;

layout (std140, push_constant) uniform PushConsts {
    mat4 u_mvp;    
} pushConsts;


vec3 rotate_vector( vec4 quat, vec3 vec )
{
    return vec + 2.0 * cross( cross( vec, quat.xyz ) + quat.w * vec, quat.xyz );
}

void main()
{
    v_texcoord = a_normal.zw;

    vec4 currentPosition = vec4( a_position.xyz, 1.0 );
    currentPosition = pushConsts.u_mvp * currentPosition;
    currentPosition /= currentPosition.w;
    
    vec3 translation = rotate_vector( vsDynamic.u_pixel_rotation, vec3( a_normal.xy, 0.0) );
    translation.xy *= vsDynamic.u_pixel_translation_scale.zw;
    
    translation += rotate_vector( vsDynamic.u_pixel_rotation, vec3( vsDynamic.u_pixel_anchor.xy, 0.0 ) );
    
    translation.xy += vsDynamic.u_pixel_translation_scale.xy;
    
    gl_Position.x = currentPosition.x + ( (translation.x ) / vsConst.u_viewport.z ) * 2.0;
    gl_Position.y = currentPosition.y - ( (translation.y ) / vsConst.u_viewport.w ) * 2.0;
    gl_Position.zw = currentPosition.zw;
    
    gl_Position.z = (gl_Position.z + gl_Position.w) / 2.0;
}
