// DECODE NTSC AND CRT EFFECTS
// https://www.shadertoy.com/view/3tVBWR

#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform float iTime;
uniform sampler2D iChannel0;

out vec4 fragColor;

const float XRES = 54.0 * 8.0;
const float YRES = 33.0 * 8.0;

#define BRIGHTNESS 1.1
#define SATURATION 0.6
#define BLUR 0.7
#define BLURSIZE 0.2
#define CHROMABLUR 0.7
#define CHROMASIZE 6.0
#define SUBCARRIER 2.1
#define CROSSTALK 0.1
#define SCANFLICKER 0.33
#define INTERFERENCE1 1.0
#define INTERFERENCE2 0.001

const float fishEyeX = 0.1;
const float fishEyeY = 0.16;
const float vignetteRounding = 160.0;
const float vignetteSmoothness = 0.7;

// ------------


#define PI 3.14159265
#define CHROMA_MOD_FREQ (0.4 * PI)

// #define IFRINGE (1.0 - FRINGE) // FRINGE is not defined, commenting out.

// Fish-eye effect
vec2 fisheye(vec2 uv) {
    uv *= vec2(1.0+(uv.y*uv.y)*fishEyeX,1.0+(uv.x*uv.x)*fishEyeY);
    return uv * 1.02;
}

float vignette(vec2 uv) {
    uv *= 1.99;
    float amount = 1.0 - sqrt(pow(abs(uv.x), vignetteRounding) + pow(abs(uv.y), vignetteRounding));
    float vhard = smoothstep(0., vignetteSmoothness, amount);
    return(vhard);
}

float random (vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))
                 * 43758.5453123);
}

const mat3 yiq_mat = mat3(
    0.2989, 0.5959, 0.2115,
    0.5870, -0.2744, -0.5229,
    0.1140, -0.3216, 0.3114
);

vec3 rgb2yiq(vec3 col) {
    return yiq_mat * col;
}

const mat3 yiq2rgb_mat = mat3(
    1.0, 1.0, 1.0,
    0.956, -0.2720, -1.1060,
    0.6210, -0.6474, 1.7046
);

vec3 yiq2rgb(vec3 yiq) {
    return yiq2rgb_mat * yiq;
}

#define KERNEL 25

float luma_filter_val(int i) {
    if (i == 0) return 0.0105; if (i == 1) return 0.0134; if (i == 2) return 0.0057;
    if (i == 3) return -0.0242; if (i == 4) return -0.0824; if (i == 5) return -0.1562;
    if (i == 6) return -0.2078; if (i == 7) return -0.185; if (i == 8) return -0.0546;
    if (i == 9) return 0.1626; if (i == 10) return 0.3852; if (i == 11) return 0.5095;
    if (i == 12) return 0.5163; if (i == 13) return 0.4678; if (i == 14) return 0.2844;
    if (i == 15) return 0.0515; if (i == 16) return -0.1308; if (i == 17) return -0.2082;
    if (i == 18) return -0.1891; if (i == 19) return -0.1206; if (i == 20) return -0.0511;
    if (i == 21) return -0.0065; if (i == 22) return 0.0114; if (i == 23) return 0.0127;
    if (i == 24) return 0.008;
    return 0.0;
}

float chroma_filter_val(int i) {
    if (i == 0) return 0.001; if (i == 1) return 0.001; if (i == 2) return 0.0001;
    if (i == 3) return 0.0002; if (i == 4) return -0.0003; if (i == 5) return 0.0062;
    if (i == 6) return 0.012; if (i == 7) return -0.0079; if (i == 8) return 0.0978;
    if (i == 9) return 0.1059; if (i == 10) return -0.0394; if (i == 11) return 0.2732;
    if (i == 12) return 0.2941; if (i == 13) return 0.1529; if (i == 14) return -0.021;
    if (i == 15) return 0.1347; if (i == 16) return 0.0415; if (i == 17) return -0.0032;
    if (i == 18) return 0.0115; if (i == 19) return 0.002; if (i == 20) return -0.0001;
    if (i == 21) return 0.0002; if (i == 22) return 0.001; if (i == 23) return 0.001;
    if (i == 24) return 0.001;
    return 0.0;
}

vec3 get(vec2 uv, float off, float d, float yscale) {
    float offd = off * d;
    return texture(iChannel0, uv + vec2(offd, yscale * offd)).xyz;
}

float peak(float x, float xpos, float scale) {
    return clamp((1.0 - x) * scale * log(1.0 / abs(x - xpos)), 0.0, 1.0);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord.xy / iResolution.xy;
    float scany = round(uv.y * YRES);
    /*
    fragColor = vec4(texture(iChannel0, uv).xyz, 1.0);
    return;
    */
    uv -= vec2(0.5);
    uv = fisheye(uv);
    float vign = vignette(uv);
    uv += vec2(0.5);
    float mframe = mod(floor(iTime * 60.0), 2.0);
    uv.y += mframe * 1.0 / YRES * SCANFLICKER;
    
    // interference
    
    float r = random(vec2(scany, iTime));
    if (r > 0.995) {r *= 3.0;}
    float ifx1 = INTERFERENCE1 * 2.0 / iResolution.x * r;
    float ifx2 = INTERFERENCE2 * (r * peak(uv.y, 0.2, 0.2));
    uv.x += ifx1 + -ifx2;
    
    // luma fringing and chroma blur
    
    float d = 1.0 / XRES * (BLURSIZE + ifx2 * 100.0);
    vec3 lsignal = vec3(0.0);
    vec3 csignal = vec3(0.0);
    for (int i = 0; i < KERNEL; i++) {
        float offset = float(i) - 12.0;
        vec3 sample_rgb = get(uv, offset, d, 0.67);
        vec3 sample_yiq = rgb2yiq(sample_rgb);
        lsignal.x += sample_yiq.x * luma_filter_val(i);

        vec3 sample_rgb_chroma = get(uv, offset, d * CHROMASIZE, 0.67);
        vec3 sample_yiq_chroma = rgb2yiq(sample_rgb_chroma);
        csignal.y += sample_yiq_chroma.y * chroma_filter_val(i);
        csignal.z += sample_yiq_chroma.z * chroma_filter_val(i);
    }
    vec3 sat = rgb2yiq(texture(iChannel0, uv).xyz);
    vec3 lumat = sat * vec3(1.0, 0.0, 0.0);
    vec3 chroat = sat * vec3(0.0, 1.0, 1.0);
    vec3 signal = lumat * (1.0 - BLUR) + BLUR * lsignal + chroat * (1.0 - CHROMABLUR) + CHROMABLUR * csignal;

    float scanl = 0.5 + 0.5 * abs(sin(PI * uv.y * YRES));
    
    // decoding chroma saturation and phase
    
    signal.x *= BRIGHTNESS;
    signal.yz *= SATURATION;
    
    // color subcarrier signal, crosstalk
    
    float chroma_phase = iTime * 60.0 * PI * 0.6667;
    float mod_phase = chroma_phase + (uv.x + uv.y * 0.1) * CHROMA_MOD_FREQ * XRES * 2.0;
    float scarrier = SUBCARRIER * length(signal.yz);
    float i_mod = cos(mod_phase);
    float q_mod = sin(mod_phase);
    
    signal.x *= CROSSTALK * scarrier * q_mod + 1.0 - ifx2 * 30.0;
    signal.y *= scarrier * i_mod + 1.0;
    signal.z *= scarrier * q_mod + 1.0;
    
    vec3 out_color = signal;
    vec3 rgb = vign * scanl * yiq2rgb(out_color);
    fragColor = vec4(rgb, 1.0);
}
