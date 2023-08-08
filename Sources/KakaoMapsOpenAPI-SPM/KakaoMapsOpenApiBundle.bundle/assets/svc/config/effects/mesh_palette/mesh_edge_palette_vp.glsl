attribute vec4 a_position;
attribute vec4 a_normal;
varying vec2 v_texcoord;
varying vec4 v_diffuse;

uniform mat4 u_mvp;
uniform vec4 u_view_scale;

const float uvWeight = 1.0 / 256.0;


void main()
{
    
    v_texcoord.x = ( a_normal.w + 128.5 ) * uvWeight;
    v_texcoord.y = 0.75;
    
    v_diffuse = vec4( 1.0, 1.0, 1.0, 1.0 );
    gl_Position = u_mvp * vec4( a_position.x, a_position.y, a_position.z * u_view_scale.z, 1.0 );
}
