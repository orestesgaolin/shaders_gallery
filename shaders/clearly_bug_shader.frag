// CC0: Clearly a bug
//   A "Happy Accident" Shader

//  Twigl: https://twigl.app?ol=true&ss=-OUOudmBPJ57CIb7rAxS
// Modified to compile for Flutter
// https://www.shadertoy.com/view/33cGDj

#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform float iTime;

out vec4 fragColor;

// This shader uses a technique called "raymarching" to render 3D
// Think of it like casting rays from your eye through each pixel into a 3D world,
// then stepping along each ray until we hit something interesting.
//
// Key concepts for C developers:
// - vec4/vec3/vec2: Like structs with x,y,z,w components (SIMD-style)
// - Swizzling: p.xy means "give me just the x,y parts of vector p"
// - mat2(): Creates a 2x2 rotation matrix from an angle
// - All math operations work on vectors component-wise
//
// ATTRIBUTION: Shader techniques inspired by (alphabetical):
//   @byt3_m3chanic
//   @FabriceNeyrat2
//   @iq
//   @shane
//   @XorDev
//   + many more

void main() {
  vec2 C = FlutterFragCoord().xy;
  vec4 O;
  
  float i = 0.0;     // Loop counter (starts at 0)
  float d = 0.0;     // Distance to nearest surface
  float z = fract(dot(C,sin(C)))-0.5;  // Ray distance + noise for anti-banding
  
  vec4 o = vec4(0.0);     // Accumulated color/lighting
  vec4 p = vec4(0.0);     // Current 3D position along ray
  
  vec2 r = iResolution.xy;  // Screen resolution
  
  for(int iter = 0; iter < 77; iter++) {
    i = float(iter);
    
    // Convert 2D pixel to 3D ray direction
    p = vec4(z*normalize(vec3(C-0.5*r,r.y)), 0.1*iTime);
    
    // Move through 3D space over time
    p.z += iTime;
    
    // Save position for lighting calculations
    O = p;
    
    // Apply rotation matrices to create fractal patterns
    // (These transform the 3D coordinates in interesting ways)
    p.xy *= mat2(cos(2.0+O.z+vec4(0,11,33,0)));
    
    // This was originally a bug in the matrix calculation
    // The incorrect transformation created an unexpectedly interesting pattern
    // Bob Ross would call this a "happy little accident"
    p.xy *= mat2(cos(O+vec4(0,11,33,0)));
    
    // Calculate color based on position and space distortion
    // The sin() creates a nice looking palette, division by dot() creates falloff
    O = (1.0+sin(0.5*O.z+length(p-O)+vec4(0,4,3,6)))
       / (0.5+2.0*dot(O.xy,O.xy));
    
    // Domain repetition, repeats the single line and the 2 planes infinitely
    p = abs(fract(p)-0.5);
    
    // Calculate distance to nearest surface
    // This combines a cylinder (length(p.xy)-.125) with 2 planes (min(p.x,p.y))
    d = abs(min(length(p.xy)-0.125,min(p.x,p.y)+1e-3))+1e-3;
    
    // Add lighting contribution (brighter when closer to surfaces)
    o += O.w/d*O;
    
    // Step forward (larger steps when far from surfaces)
    z += 0.6*d;
  }
  
  // tanh() compresses the accumulated brightness to 0-1 range
  // (Like HDR tone mapping in photography)
  O = tanh(o/2e4);
  
  fragColor = O;
}