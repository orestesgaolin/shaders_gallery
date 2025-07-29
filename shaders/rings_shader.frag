// https://www.shadertoy.com/view/Xtj3DW
// Created by Pol Jeremias - pol/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Modified to compile for Flutter

#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform float iTime;
uniform float interactionStrength;
uniform vec2 interactionPoint;

out vec4 fragColor;

float drawCircle(float r, float polarRadius, float thickness)
{
	return 	smoothstep(r, r + thickness, polarRadius) - 
        	smoothstep(r + thickness, r + 2.0 * thickness, polarRadius);
}

float sin01(float v)
{
	return 0.5 + 0.5 * sin(v);
}

// Simple bitmap font for digits 0-9 - improved version
float digit(vec2 p, float d) {
    // Ensure p is in [0,1] range
    if (p.x < 0.0 || p.x > 1.0 || p.y < 0.0 || p.y > 1.0) return 0.0;
    
    // Create thicker lines for better visibility
    float thick = 0.15;
    
    if (abs(d - 0.0) < 0.1) {
        // Outer rectangle minus inner rectangle
        float outer = step(0.0, p.x) * step(p.x, 1.0) * step(0.0, p.y) * step(p.y, 1.0);
        float inner = step(thick, p.x) * step(p.x, 1.0-thick) * step(thick, p.y) * step(p.y, 1.0-thick);
        return outer - inner;
    }
    if (abs(d - 1.0) < 0.1) {
        // Vertical line in the middle
        return step(0.4, p.x) * step(p.x, 0.6);
    }
    if (abs(d - 2.0) < 0.1) {
        // Top, middle, bottom horizontal lines + corners
        float top = step(0.8, p.y);
        float middle = step(0.4, p.y) * step(p.y, 0.6);
        float bottom = step(p.y, 0.2);
        float right_top = step(0.6, p.x) * step(0.4, p.y);
        float left_bottom = step(p.x, 0.4) * step(p.y, 0.6);
        return top + middle + bottom + right_top + left_bottom;
    }
    if (abs(d - 3.0) < 0.1) {
        // Right vertical line + three horizontal lines
        float right = step(0.6, p.x);
        float top = step(0.8, p.y);
        float middle = step(0.4, p.y) * step(p.y, 0.6);
        float bottom = step(p.y, 0.2);
        return clamp(right + top + middle + bottom, 0.0, 1.0);
    }
    if (abs(d - 4.0) < 0.1) {
        // Left vertical (top half), right vertical (full), middle horizontal
        float left_top = step(p.x, 0.4) * step(0.4, p.y);
        float right = step(0.6, p.x);
        float middle = step(0.4, p.y) * step(p.y, 0.6);
        return clamp(left_top + right + middle, 0.0, 1.0);
    }
    if (abs(d - 5.0) < 0.1) {
        // Similar to 2 but with left top and right bottom
        float top = step(0.8, p.y);
        float middle = step(0.4, p.y) * step(p.y, 0.6);
        float bottom = step(p.y, 0.2);
        float left_top = step(p.x, 0.4) * step(0.4, p.y);
        float right_bottom = step(0.6, p.x) * step(p.y, 0.6);
        return clamp(top + middle + bottom + left_top + right_bottom, 0.0, 1.0);
    }
    // Add more digits...
    return 0.0;
}

// Render a number at position
float renderNumber(vec2 uv, vec2 pos, float number, float scale) {
    vec2 p = (uv - pos) / scale;
    if (p.x < 0.0 || p.x > 3.0 || p.y < 0.0 || p.y > 1.0) return 0.0;
    
    // Use floating point math instead of integer operations
    float num = floor(mod(number, 1000.0)); // Limit to 0-999
    float hundreds = floor(num / 100.0);
    float tens = floor(mod(num, 100.0) / 10.0);
    float ones = mod(num, 10.0);
    
    float text = 0.0;
    if (p.x < 1.0) {
        if (hundreds == 0.0) text = digit(p, 0);
        else if (hundreds == 1.0) text = digit(p, 1);
        else if (hundreds == 2.0) text = digit(p, 2);
        else if (hundreds == 3.0) text = digit(p, 3);
        else if (hundreds == 4.0) text = digit(p, 4);
        else if (hundreds == 5.0) text = digit(p, 5);
        else if (hundreds == 6.0) text = digit(p, 6);
        else if (hundreds == 7.0) text = digit(p, 7);
        else if (hundreds == 8.0) text = digit(p, 8);
        else if (hundreds == 9.0) text = digit(p, 9);
    }
    else if (p.x < 2.0) {
        vec2 digitPos = vec2(p.x - 1.0, p.y);
        if (tens == 0.0) text = digit(digitPos, 0);
        else if (tens == 1.0) text = digit(digitPos, 1);
        else if (tens == 2.0) text = digit(digitPos, 2);
        else if (tens == 3.0) text = digit(digitPos, 3);
        else if (tens == 4.0) text = digit(digitPos, 4);
        else if (tens == 5.0) text = digit(digitPos, 5);
        else if (tens == 6.0) text = digit(digitPos, 6);
        else if (tens == 7.0) text = digit(digitPos, 7);
        else if (tens == 8.0) text = digit(digitPos, 8);
        else if (tens == 9.0) text = digit(digitPos, 9);
    }
    else if (p.x < 3.0) {
        vec2 digitPos = vec2(p.x - 2.0, p.y);
        if (ones == 0.0) text = digit(digitPos, 0);
        else if (ones == 1.0) text = digit(digitPos, 1);
        else if (ones == 2.0) text = digit(digitPos, 2);
        else if (ones == 3.0) text = digit(digitPos, 3);
        else if (ones == 4.0) text = digit(digitPos, 4);
        else if (ones == 5.0) text = digit(digitPos, 5);
        else if (ones == 6.0) text = digit(digitPos, 6);
        else if (ones == 7.0) text = digit(digitPos, 7);
        else if (ones == 8.0) text = digit(digitPos, 8);
        else if (ones == 9.0) text = digit(digitPos, 9);
    }
    
    return text;
}

void main()
{
    vec2 fragCoord = FlutterFragCoord().xy;
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    // Replace sound input with interaction strength and animated values
    float rstandard = interactionStrength * 2.0 + 0.5 * sin(iTime * 0.5);
    
    // Center the coordinates and apply the aspect ratio
    vec2 p = uv - vec2(0.5) + vec2(0.05, 0.05) * rstandard;
    p.x *= iResolution.x / iResolution.y;

    // Add interaction point influence
    vec2 interactionUV = interactionPoint / iResolution.xy;
    interactionUV.x *= iResolution.x / iResolution.y;
    interactionUV -= vec2(0.5);
    float distToInteraction = length(p - interactionUV);
    float interactionInfluence = exp(-distToInteraction * 3.0) * interactionStrength;

    // Calculate polar coordinates
    float pr = length(p);
    float pa = atan(p.y, p.x);
    
    // Fix the seam by normalizing the angle properly
    // Convert from [-π, π] to [0, 2π] to avoid discontinuity
    if (pa < 0.0) {
        pa += 6.28318530718; // Add 2π
    }
    
    // Retrieve the information from the texture - replace with mathematical functions
    float idx = pa / 6.28318530718;   // 0 to 1 (using 2π instead of π)
    float idx2 = idx * 6.28318530718; // 0 to 2π
    
    // Replace microphone data with animated and interaction-based values
    vec2 react = vec2(sin(idx2 + iTime), cos(idx2 + iTime * 0.7)) * (rstandard + interactionInfluence);
    
    // Draw the circles
    float o = 0.0;
    float inc = 0.0;
    
    for( float i = 1.0 ; i < 8.0 ; i += 1.0 )
    {
        float baseradius = 0.3 * ( 0.3 + sin01(rstandard + iTime * 0.2) ); 
        float radius = baseradius + inc;

        radius += 0.01 * ( sin01(pa * i + iTime * (i - 1.0) ) );
        radius += 0.005 * interactionInfluence * sin(iTime * 2.0 + i);
        
    	o += drawCircle(radius, pr, 0.008 * (1.0 + react.x * (i - 1.0)));
        
        inc += 0.005;
    }
    
    // Calculate the background color    
    vec3 bcol = vec3(1.0, 0.22, 0.5 - 0.4*p.y) * (1.0 - 0.6 * pr * react.x);
    vec3 col = mix(bcol, vec3(1.0,1.0,0.7), o);
    
    // Add interaction color tint
    col += vec3(0.1, 0.0, 0.2) * interactionInfluence;
    
    // Add text overlay for mouse coordinates
    float textScale = 0.02;
    vec2 textPos = vec2(0.02, 0.15); // Bottom left area
    
    // First, add a simple test rectangle to ensure we can see something
    float testRect = step(0.01, uv.x) * step(uv.x, 0.15) * step(0.05, uv.y) * step(uv.y, 0.20);
    col = mix(col, vec3(0.0, 0.0, 0.0), testRect * 0.7); // Dark background for text
    
    // Display X coordinate (limit to 0-999 range)
    float mouseX = mod(interactionPoint.x, 1000.0);
    float textX = renderNumber(uv, textPos, mouseX, textScale);
    
    // Display Y coordinate below X (limit to 0-999 range)
    float mouseY = mod(interactionPoint.y, 1000.0);
    float textY = renderNumber(uv, textPos + vec2(0.0, -0.04), mouseY, textScale);
    
    // Display interaction strength (scale to 0-99)
    float strength = mod(interactionStrength * 99.0, 100.0);
    float textS = renderNumber(uv, textPos + vec2(0.0, -0.08), strength, textScale);
    
    // Make text more visible with better contrast
    vec3 textColor = vec3(1.0, 1.0, 1.0); // White text
    float textMask = textX + textY + textS;
    
    // Apply text
    col = mix(col, textColor, textMask);
    
	fragColor = vec4(col, 1.0);
}