#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform float iTime;
uniform vec2 iMouse;

out vec4 fragColor;

#define PI 3.14159265359
#define TAU 6.28318530718

float hash21(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float sum = 0.0;
    float amp = 0.5;
    float freq = 1.0;
    for (int i = 0; i < 6; i++) {
        sum += noise(p * freq) * amp;
        amp *= 0.5;
        freq *= 2.0;
    }
    return sum;
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;

    vec2 uv = fragCoord / iResolution.xy;
    vec2 aspect = vec2(iResolution.x / iResolution.y, 1.0);
    uv = (uv - 0.5) * aspect;

    vec2 mouse = (iMouse.xy / iResolution.xy - 0.5) * aspect;
    float mouseDist = length(uv - mouse);

    vec3 col = vec3(0.0);

    float radius = 0.3 + sin(iTime * 0.5) * 0.02;
    float d = length(uv);

    float angle = atan(uv.y, uv.x);
    float wave = sin(angle * 3.0 + iTime) * 0.1;
    float wave2 = cos(angle * 5.0 - iTime * 1.3) * 0.08;

    float noise1 = fbm(uv * 3.0 + iTime * 0.1);
    float noise2 = fbm(uv * 5.0 - iTime * 0.2);

    vec3 orbColor = vec3(0.2, 0.6, 1.0);
    float orb = smoothstep(radius + wave + wave2, radius - 0.1 + wave + wave2, d);

    vec3 gradient1 = vec3(0.8, 0.2, 0.5) * sin(angle + iTime);
    vec3 gradient2 = vec3(0.2, 0.5, 1.0) * cos(angle - iTime * 0.7);

    float particles = 0.0;
    for (float i = 0.0; i < 3.0; i++) {
        vec2 particlePos = vec2(
            sin(iTime * (0.5 + i * 0.2)) * 0.5,
            cos(iTime * (0.3 + i * 0.2)) * 0.5
        );
        particles += smoothstep(0.05, 0.0, length(uv - particlePos));
    }

    col += orb * mix(orbColor, gradient1, noise1);
    col += orb * mix(gradient2, orbColor, noise2) * 0.5;
    col += particles * vec3(0.5, 0.8, 1.0);
    col += exp(-d * 4.0) * vec3(0.2, 0.4, 0.8) * 0.5;
    col += exp(-mouseDist * 8.0) * vec3(0.5, 0.7, 1.0) * 0.2;

    fragColor = vec4(col, 1.0);
}