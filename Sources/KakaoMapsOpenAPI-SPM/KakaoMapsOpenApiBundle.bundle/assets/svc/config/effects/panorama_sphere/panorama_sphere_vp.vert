#version 450

layout (location = 0) in vec3 a_position;
layout (location = 1) in vec2 a_uv;
layout (location = 2) in vec2 a_uv2;

layout (location = 0) out vec3 v_texcoord;
layout (location = 1) out vec2 v_depth;

layout (constant_id = 0) const int MAX_TEXTURE_DESCRIPTORS = 16;

layout (set = 0, binding = 0) uniform sampler u_depth_sampler;
layout (set = 1, binding = 0) uniform texture2D u_depth_texture[MAX_TEXTURE_DESCRIPTORS];

layout (std140, push_constant) uniform PushConsts {
    mat4 u_mvp;
    int u_index1;
    float u_distance_max;
} pushConsts;

vec3 getNormal(in vec2 rg) {
    
    float tz = floor(rg.y / 64.); //8 * 8
    float z = ((rg.x - floor(rg.x / 2.) * 2.) * 4.) + tz;
    float y = floor((rg.y - tz * 64.) / 8.);
    float x = floor(mod(rg.y, 8.));
    
    if (x > 3.) { x += -8.; }
    if (y > 3.) { y += -8.; }
    if (z > 3.) { z += -8.; }
    
    return vec3(x, y, z);
}

float getDepth(in vec3 position, in vec2 uv, in float maxValue) {
    if(uv.x > 0.98)
    {
        uv.x = 0.0;
    }   
    
    vec4 depthColor = texture(sampler2D(u_depth_texture[pushConsts.u_index1], u_depth_sampler), uv);
    depthColor *= 255.;
    
    float depth = pow(maxValue + 1., depthColor.b / 256.) - 1.;

    if ( depth <= 3.0 ) {
        vec3 normal = getNormal(depthColor.rg);
        if( length(normal) == 0.0 )
//        if( uv.y < 0.6 )
        {
            depth = maxValue;
        }
        else
        {
            depth = 3.0 + 3.0 * (length(position) / abs(position.z) - 1.0);
        }
    }
    
    return depth;
}
                                
void main()
{
    vec3 position = a_position;
    float depth = getDepth(position, a_uv2, pushConsts.u_distance_max);
    depth = 16.0;
    v_depth.x = depth;
    v_depth.y = pushConsts.u_distance_max;
    position *= depth;
    vec3 texcoord = vec3(a_uv.xy, 1.0);
    texcoord *= length(position) / pushConsts.u_distance_max;
    v_texcoord = texcoord;
    gl_Position = pushConsts.u_mvp * vec4( position, 1.0 );
    gl_Position.z = (gl_Position.z + gl_Position.w) / 2.0;
}

