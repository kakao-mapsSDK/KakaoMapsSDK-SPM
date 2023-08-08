attribute vec4 a_position; // x: x screen pos
                           // y: y screen pos
                           // z: u texture coord
                           // w: v texture coord
attribute vec4 a_color;    // x: dimmed color weight
                           // w: alpha weight
varying vec2 v_texcoord;
varying vec4 v_diffuse;
uniform vec4 u_viewport;
float inverseWeight = 1.0 / 255.0;


void main()
{
    v_texcoord = a_position.zw;
    v_diffuse = vec4( a_color.x, 1.0, 1.0, a_color.w * inverseWeight );
    gl_Position.x = a_position.x * 2.0 / u_viewport.z - 1.0;
    gl_Position.y = ( 1.0 - a_position.y / u_viewport.w ) * 2.0 - 1.0;
    gl_Position.z = 0.0;
    gl_Position.w = 1.0;
}
