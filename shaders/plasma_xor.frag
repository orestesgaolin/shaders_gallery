// modified to be compiled to Flutter by @OrestesGaolin
/*
    "Plasma" by @XorDev
    
    X Post:
    x.com/XorDev/status/1894123951401378051
*/
#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform float iTime;

out vec4 fragColor;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 I = fragCoord;
    vec4 O = vec4(0.0);
    //Resolution for scaling
    vec2 r = iResolution.xy;
    
    // Add padding factor to ensure the entire ball fits
    float padding = 1.5; // Adjust this value as needed (1.5 = 50% padding)

    //Centered, ratio corrected, coordinates with padding
    vec2 p = ((I+I-r) / r.y) * padding;
    
    //Z depth
    vec2 z = vec2(0.0);
    //Add depth value
    z += 4.0 - 4.0 * abs(0.7 - dot(p, p));
    //Fluid coordinates
    vec2 f = p * z;
    
    //Clear frag color and initialize iterator
    O = vec4(0.0);
    vec2 i = vec2(0.0, 0.0);
    
    //Loop 8 times with standard loop format
    for(int j = 0; j < 8; j++) {
        i.y = float(j);
        //Add fluid waves
        f += cos(f.yx * i.y + i + iTime) / vec2(i.y + 1.0) + 0.7;
        //Set color waves and line brightness
        O += (sin(f) + vec2(1.0)).xyyx * abs(f.x - f.y);
    }
    
    //Tonemap, fade edges and color gradient
    O = tanh(7.0 * exp(z.x - 4.0 - p.y * vec4(-1.0, 1.0, 2.0, 0.0)) / O);
    fragColor = O;
}