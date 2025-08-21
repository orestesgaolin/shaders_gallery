#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform float iTime;

out vec4 fragColor;

void main()
{
    vec2 fragCoord = FlutterFragCoord().xy;
	vec2 uv = (fragCoord - .5* iResolution.xy ) / iResolution.y; // Thanks @FabriceNeyret2 for this refactored line.
    // Old code:
    // vec2 uv = fragCoord.xy / iResolution.xy; // 0 <> 1.
	// uv -= .5; // -0.5 <> 0.5
	// uv.x *= iResolution.x/iResolution.y;
    
    float d = length(uv);
    float ti = iTime;
    float r = 0.3;
    
    float x = (r*(cos(ti*2.0)+1.0)/2.0)+0.001;
    float c = smoothstep(r, r-x, d);
    
	fragColor = vec4(vec3(c), 1.0);
}