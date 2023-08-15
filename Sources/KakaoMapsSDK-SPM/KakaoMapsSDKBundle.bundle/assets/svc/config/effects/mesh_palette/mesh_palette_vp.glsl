attribute vec4 a_position;
attribute vec4 a_normal;
varying vec2 v_texcoord;
varying vec4 v_diffuse;

uniform mat4 u_mvp;
uniform vec4 u_view_scale;

const vec3 lightDirection01 = vec3( 0, 0, 1 );
const vec3 lightDirection02 = vec3( 0, -1, 0 );
const vec3 lightDirection03 = vec3( 0.5773502691896258, 0.5773502691895258, 0.5773502691896258 );

const float nWeight = 1.0 / 127.0;
const float uvWeight = 1.0 / 256.0;


void main()
{
    
    float underShading = min( 1.0, smoothstep( 0.0, 4.0, a_position.z ) + 0.93 );
    
    vec3 n = vec3( a_normal.x, a_normal.y, a_normal.z ) * nWeight;
    v_texcoord.x = ( a_normal.w + 128.5 ) * uvWeight;
    v_texcoord.y = 0.25;
    
    float light01Dot = dot( lightDirection01, n.xyz );
    float light02Dot = dot( lightDirection02, n.xyz );
    float light03Dot = dot( lightDirection03, n.xyz );
    
    light01Dot = ( light01Dot + 1.0 ) * 0.5;
    light02Dot = ( light02Dot + 1.0 ) * 0.5;
    light03Dot = ( light03Dot + 1.0 ) * 0.5;
    float color = smoothstep( 0.0, 1.0,light01Dot * 0.6 + light02Dot * 0.35 + light03Dot * 0.25 + 0.3 );
    v_diffuse = vec4( color * underShading, color * underShading, color * underShading, 1.0 );
    
    gl_Position = u_mvp * vec4( a_position.x, a_position.y, a_position.z * u_view_scale.z, 1.0 );
}
