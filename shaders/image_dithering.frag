#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

// Image Dithering by paper.design (https://shaders.paper.design)
// Ported to Flutter from https://github.com/paper-design/shaders (MIT)
// A dithering image filter applied to the widget rendered behind it.
// Cycles through the 4 dithering modes over time:
// random -> 2x2 Bayer -> 4x4 Bayer -> 8x8 Bayer.
// The Bayer thresholds are computed procedurally (instead of the original
// const int arrays, which are not supported by all Flutter shader backends).
// Colors match the "Default" preset on shaders.paper.design.

uniform vec2 iResolution;
uniform float iTime;
uniform float iImageAspect;
uniform float iImage2Aspect;
uniform float iImage3Aspect;
uniform sampler2D u_image;
uniform sampler2D u_image2;
uniform sampler2D u_image3;

out vec4 fragColor;

const vec4 COLOR_FRONT = vec4(0.580, 1.0, 0.686, 1.0);     // #94ffaf
const vec4 COLOR_BACK = vec4(0.0, 0.047, 0.220, 1.0);      // #000c38
const vec4 COLOR_HIGHLIGHT = vec4(0.918, 1.0, 0.580, 1.0); // #eaff94
const float PX_SIZE = 2.0;
const float COLOR_STEPS = 2.0;
const bool ORIGINAL_COLORS = false;
const bool INVERTED = false;
const float TYPE_CYCLE_SECONDS = 3.0;
const float IMAGE_CYCLE_SECONDS = 6.0;
const float IMAGE_FADE_SECONDS = 0.7;

// Maps canvas UV to image UV so the image covers the canvas (BoxFit.cover)
vec2 coverUV(vec2 uv, float canvasAspect, float imageAspect) {
  vec2 scale = (canvasAspect > imageAspect)
    ? vec2(1.0, imageAspect / canvasAspect)
    : vec2(canvasAspect / imageAspect, 1.0);
  return (uv - .5) * scale + .5;
}

// All images stay bound and are sampled every frame so their GPU textures
// never go cold; rebinding a texture mid-animation causes a frame drop.
// The rotation and crossfade are pure uniform math on iTime.
vec4 sampleImages(vec2 uv, float canvasAspect) {
  float cyclePos = mod(iTime, IMAGE_CYCLE_SECONDS);
  float slot = mod(floor(iTime / IMAGE_CYCLE_SECONDS), 3.0);
  float fade = smoothstep(IMAGE_CYCLE_SECONDS - IMAGE_FADE_SECONDS, IMAGE_CYCLE_SECONDS, cyclePos);
  vec4 img1 = texture(u_image, coverUV(uv, canvasAspect, iImageAspect));
  vec4 img2 = texture(u_image2, coverUV(uv, canvasAspect, iImage2Aspect));
  vec4 img3 = texture(u_image3, coverUV(uv, canvasAspect, iImage3Aspect));
  vec4 current = (slot < .5) ? img1 : ((slot < 1.5) ? img2 : img3);
  vec4 next = (slot < .5) ? img2 : ((slot < 1.5) ? img3 : img1);
  return mix(current, next, fade);
}

float hash21(vec2 p) {
  p = fract(p * vec2(0.3183099, 0.3678794)) + 0.1;
  p += dot(p, p + 19.19);
  return fract(p.x * p.y);
}

// Procedural Bayer matrix threshold, equivalent to the classic
// recursive construction: M(2n) = [[4M(n), 4M(n)+2], [4M(n)+3, 4M(n)+1]].
// The base 2x2 cell value for bits (x, y) is (2x + 3y) mod 4.
float getBayerValue(vec2 pxUV, int levels) {
  float size = pow(2.0, float(levels));
  vec2 p = floor(fract(pxUV / size) * size);
  float v = 0.0;
  float weight = size * size / 4.0;
  for (int i = 0; i < 3; i++) {
    float levelOn = i < levels ? 1.0 : 0.0;
    vec2 f = mod(p, 2.0);
    v += levelOn * mod(2.0 * f.x + 3.0 * f.y, 4.0) * weight;
    p = floor(p / 2.0);
    weight /= 4.0;
  }
  return v / (size * size);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;

  float pxSize = PX_SIZE;
  vec2 pxSizeUV = fragCoord - .5 * iResolution;
  pxSizeUV /= pxSize;
  vec2 canvasPixelizedUV = (floor(pxSizeUV) + .5) * pxSize;
  vec2 normalizedUV = canvasPixelizedUV / iResolution + .5;

  vec2 ditheringNoiseUV = canvasPixelizedUV;
  vec4 image = sampleImages(normalizedUV, iResolution.x / iResolution.y);

  int type = 1 + int(mod(floor(iTime / TYPE_CYCLE_SECONDS), 4.0));
  float dithering = 0.0;

  float lum = dot(vec3(.2126, .7152, .0722), image.rgb);
  lum = INVERTED ? (1. - lum) : lum;

  if (type == 1) {
    dithering = step(hash21(ditheringNoiseUV), lum);
  } else if (type == 2) {
    dithering = getBayerValue(pxSizeUV, 1);
  } else if (type == 3) {
    dithering = getBayerValue(pxSizeUV, 2);
  } else {
    dithering = getBayerValue(pxSizeUV, 3);
  }

  float colorSteps = max(floor(COLOR_STEPS), 1.);
  vec3 color = vec3(0.0);
  float opacity = 1.;

  dithering -= .5;
  float brightness = clamp(lum + dithering / colorSteps, 0.0, 1.0);
  brightness = mix(0.0, brightness, image.a);
  float quantLum = floor(brightness * colorSteps + 0.5) / colorSteps;

  if (ORIGINAL_COLORS == true) {
    vec3 normColor = image.rgb / max(lum, 0.001);
    color = normColor * quantLum;

    float quantAlpha = floor(image.a * colorSteps + 0.5) / colorSteps;
    opacity = mix(quantLum, 1., quantAlpha);
  } else {
    vec3 fgColor = COLOR_FRONT.rgb * COLOR_FRONT.a;
    float fgOpacity = COLOR_FRONT.a;
    vec3 bgColor = COLOR_BACK.rgb * COLOR_BACK.a;
    float bgOpacity = COLOR_BACK.a;
    vec3 hlColor = COLOR_HIGHLIGHT.rgb * COLOR_HIGHLIGHT.a;
    float hlOpacity = COLOR_HIGHLIGHT.a;

    fgColor = mix(fgColor, hlColor, step(1.02 - .02 * colorSteps, brightness));
    fgOpacity = mix(fgOpacity, hlOpacity, step(1.02 - .02 * colorSteps, brightness));

    color = fgColor * quantLum;
    opacity = fgOpacity * quantLum;
    color += bgColor * (1.0 - opacity);
    opacity += bgOpacity * (1.0 - opacity);
  }

  fragColor = vec4(color, opacity);
}
