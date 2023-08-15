#version 450

layout (location = 0) in vec4 a_position;
layout (location = 1) in vec4 a_normal;

layout (location = 0) out vec2 v_texcoord;
layout (location = 1) out vec4 v_diffuse;


layout (set = 1, binding = 0) uniform VsDynamic {
    vec4 u_diffuse_color;
    vec4 u_pixel_rotation;
    vec4 u_pixel_translation_scale;
    vec4 u_pixel_anchor;
} vsDynamic;

layout (set = 0, binding = 0) uniform VsConst {
    vec4 u_viewport;
} vsConst;

layout (push_constant) uniform PushConsts {
    mat4 u_sprite_matrix;
    vec4 u_sprite_space;
} pushConsts;


vec3 rotate_vector( vec4 quat, vec3 vec )
{
    return vec + 2.0 * cross( cross( vec, quat.xyz ) + quat.w * vec, quat.xyz );
}


/*
----------------------------------------------------

    parameters of calcPosition

---------------------------------------------------
    - for world space sprite
---------------------------------------------------
    A = 2.0;
    B = -2.0;
    C = 1.0;
    D = 0.0;
    transform = mvp
----------------------------------------------------
    - for screen space sprite
---------------------------------------------------
    A = viewport width;
    B = viewport height;
    C = 0.0;
    D = 1.0;
    transform = indentity matrix
---------------------------------------------------
*/

vec4 calcPosition(float A, float B, float C, float D, mat4 transform)
{
    vec4 currentPosition = transform * a_position;
    currentPosition /= currentPosition.w;

    float x = currentPosition.x * (2.0 / A) - D;
    float y = D - currentPosition.y * (2.0 / B);
    float z = -D + currentPosition.z * C;

    return vec4(x, y, z, 1.0);
}

void main()
{
    v_texcoord = a_normal.zw;
    
    v_diffuse = vec4( vsDynamic.u_diffuse_color.xyz, a_position.w * vsDynamic.u_diffuse_color.w );


    //mat4 u_sprite_matrix = mat4(1.0);
    //vec4 u_sprite_space = vsDynamic.u_viewport;
    vec4 currentPosition = calcPosition(pushConsts.u_sprite_space[0],
    pushConsts.u_sprite_space[1],
    pushConsts.u_sprite_space[2],
    pushConsts.u_sprite_space[3],
                                        pushConsts.u_sprite_matrix);

    vec3 translation = rotate_vector( vsDynamic.u_pixel_rotation, vec3( a_normal.xy, 0.0) );
    translation.xy *= vsDynamic.u_pixel_translation_scale.zw;

    translation += rotate_vector( vsDynamic.u_pixel_rotation, vec3( vsDynamic.u_pixel_anchor.xy, 0.0 ) );
    
    translation.xy += vsDynamic.u_pixel_translation_scale.xy;

    gl_Position.x = currentPosition.x + ( translation.x / vsConst.u_viewport.z ) * 2.0;
    gl_Position.y = currentPosition.y - ( translation.y / vsConst.u_viewport.w ) * 2.0 ;
    gl_Position.zw = currentPosition.zw;
    
    gl_Position.z = (gl_Position.z + gl_Position.w) / 2.0;
}
