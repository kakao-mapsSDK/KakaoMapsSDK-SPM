attribute vec4 a_position;
attribute vec4 a_normal;

varying vec2 v_texcoord;
varying vec4 v_diffuse;

uniform vec4 u_viewport;
uniform vec4 u_pixel_rotation;

uniform mat4 u_mvp;

uniform vec4 u_pixel_translation_scale;
uniform vec4 u_pixel_anchor;

vec3 rotate_vector( vec4 quat, vec3 vec )
{
    return vec + 2.0 * cross( cross( vec, quat.xyz ) + quat.w * vec, quat.xyz );
}

void main()
{
    v_texcoord = a_normal.zw;
    v_diffuse = vec4( 0.0, 0.0, 0.0, a_position.w );

    vec4 currentPosition = vec4( a_position.xyz, 1.0 );
    currentPosition = u_mvp * currentPosition;
    currentPosition /= currentPosition.w;
    
    vec3 translation = rotate_vector( u_pixel_rotation, vec3( a_normal.xy, 0.0) );
    translation.xy *= u_pixel_translation_scale.zw;
    
    translation += rotate_vector( u_pixel_rotation, vec3( u_pixel_anchor.xy, 0.0 ) );
    
    translation.xy += u_pixel_translation_scale.xy;
    
    gl_Position.x = currentPosition.x + ( (translation.x ) / u_viewport.z ) * 2.0;
    gl_Position.y = currentPosition.y - ( (translation.y ) / u_viewport.w ) * 2.0;
    gl_Position.zw = currentPosition.zw;
}
