// Converted to Flutter with Claude Sonnet 3.7
#version 460 core
precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform float iTime;

out vec4 fragColor;

void main()
{
    // Get fragment coordinates and flip the y-axis
    vec2 fragCoord = FlutterFragCoord().xy;
    fragCoord.y = iResolution.y - fragCoord.y;
    
    // Initialize fragColor
    fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    
    // Declare all variables at the beginning
    float i = 0.0;
    float z = 0.0;
    float f = 0.0;
    vec3 p;
    
    // Main shader loop with explicit initialization
    for(i = 0.0; i < 5e1; i += 1.0) {
        p = z * (vec3(fragCoord, 0.0) * 2.0 - vec3(iResolution.xy, iResolution.y)) / iResolution.y;
        p.z += 9.0;
        
        // Unroll the inner loop completely to avoid loop constructs
        f = 1.0;
        p += sin(round(p.zxy/0.1) * 0.1 * f - iTime)/f;
        f = 2.0;
        p += sin(round(p.zxy/0.1) * 0.1 * f - iTime)/f;
        f = 3.0;
        p += sin(round(p.zxy/0.1) * 0.1 * f - iTime)/f;
        f = 4.0;
        p += sin(round(p.zxy/0.1) * 0.1 * f - iTime)/f;
        f = 5.0;
        p += sin(round(p.zxy/0.1) * 0.1 * f - iTime)/f;
        f = 6.0;
        p += sin(round(p.zxy/0.1) * 0.1 * f - iTime)/f;
        
        f = 0.003 + 0.1 * abs(length(p) - 5.0);
        z += f;
        fragColor.rgb += (p/z + 0.8)/f;
    }
    
    // Apply final transformation
    fragColor = vec4(tanh(fragColor.rgb / 2e3), 1.0);
}