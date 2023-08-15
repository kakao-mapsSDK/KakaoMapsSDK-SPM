attribute vec4 a_position;
attribute vec4 a_normal;

varying vec2 v_texcoord;
varying vec4 v_diffuse;

uniform vec4 u_viewport;
uniform vec4 u_pixel_rotation;
uniform vec4 u_diffuse_color;
uniform mat4 u_mvp;
uniform mat4 u_sprite_matrix;
uniform vec4 u_sprite_space;

uniform vec4 u_pixel_translation_scale;
uniform vec4 u_pixel_anchor;

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

vec3 rotate_vector( vec4 quat, vec3 vec )
{
    return vec + 2.0 * cross( cross( vec, quat.xyz ) + quat.w * vec, quat.xyz );
}

void main()
{
    v_texcoord = a_normal.zw;
    v_diffuse = vec4( u_diffuse_color.xyz, a_position.w * u_diffuse_color.w );

    vec4 currentPosition = calcPosition(u_sprite_space[0], u_sprite_space[1], u_sprite_space[2], u_sprite_space[3], u_sprite_matrix);

    vec3 translation = rotate_vector( u_pixel_rotation, vec3( a_normal.xy, 0.0) );
    translation.xy *= u_pixel_translation_scale.zw;

    translation += rotate_vector( u_pixel_rotation, vec3( u_pixel_anchor.xy, 0.0 ) );

    translation.xy += u_pixel_translation_scale.xy;

    gl_Position.x = currentPosition.x + ( (translation.x ) / u_viewport.z ) * 2.0;
    gl_Position.y = currentPosition.y - ( (translation.y ) / u_viewport.w ) * 2.0;
    gl_Position.zw = currentPosition.zw;
}
