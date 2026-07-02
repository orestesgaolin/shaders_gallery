#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

// Halftone CMYK by paper.design (https://shaders.paper.design)
// Ported to Flutter from https://github.com/paper-design/shaders (MIT)
// CMYK halftone printing effect applied to the widget rendered behind it,
// with rotated screen angles per ink channel (C 15deg, M 75deg, Y 0deg, K 45deg).
// Parameter values below match the "Default" (ink) preset on shaders.paper.design.

uniform vec2 iResolution;
uniform sampler2D u_image;
uniform sampler2D u_noiseTexture;

out vec4 fragColor;

const vec4 COLOR_BACK = vec4(0.984, 0.980, 0.961, 1.0); // #fbfaf5
const vec4 COLOR_C = vec4(0.0, 0.706, 1.0, 1.0);        // #00b4ff
const vec4 COLOR_M = vec4(0.988, 0.318, 0.624, 1.0);    // #fc519f
const vec4 COLOR_Y = vec4(1.0, 0.847, 0.0, 1.0);        // #ffd800
const vec4 COLOR_K = vec4(0.137, 0.122, 0.125, 1.0);    // #231f20
const float SIZE = 0.2;
const float MIN_DOT = 0.15;
const float CONTRAST = 1.0;
const float SOFTNESS = 1.0;
const float GRAIN_SIZE = 0.5;
const float GRAIN_MIXER = 0.0;
const float GRAIN_OVERLAY = 0.0;
const float GRID_NOISE = 0.2;
const float FLOOD_C = 0.15;
const float FLOOD_M = 0.0;
const float FLOOD_Y = 0.0;
const float FLOOD_K = 0.0;
const float GAIN_C = 0.3;
const float GAIN_M = 0.0;
const float GAIN_Y = 0.2;
const float GAIN_K = 0.0;

const float shiftC = -.5;
const float shiftM = -.25;
const float shiftY = .2;
const float shiftK = 0.;

// Precomputed sin/cos for rotation angles (15deg, 75deg, 0deg, 45deg)
const float cosC = 0.9659258;  const float sinC = 0.2588190;
const float cosM = 0.2588190;  const float sinM = 0.9659258;
const float cosY = 1.0;        const float sinY = 0.0;
const float cosK = 0.7071068;  const float sinK = 0.7071068;

vec2 randomRG(vec2 p) {
  vec2 uv = floor(p) / 100. + .5;
  return texture(u_noiseTexture, fract(uv)).rg;
}

vec3 hash23(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * vec3(0.3183099, 0.3678794, 0.3141592)) + 0.1;
  p3 += dot(p3, p3.yzx + 19.19);
  return fract(vec3(p3.x * p3.y, p3.y * p3.z, p3.z * p3.x));
}

float sst(float edge0, float edge1, float x) {
  return smoothstep(edge0, edge1, x);
}

vec3 valueNoise3(vec2 st) {
  vec2 i = floor(st);
  vec2 f = fract(st);
  vec3 a = hash23(i);
  vec3 b = hash23(i + vec2(1.0, 0.0));
  vec3 c = hash23(i + vec2(0.0, 1.0));
  vec3 d = hash23(i + vec2(1.0, 1.0));
  vec2 u = f * f * (3.0 - 2.0 * f);
  vec3 x1 = mix(a, b, u.x);
  vec3 x2 = mix(c, d, u.x);
  return mix(x1, x2, u.y);
}

float getUvFrame(vec2 uv, vec2 pad) {
  float left   = smoothstep(-pad.x, 0., uv.x);
  float right  = smoothstep(1. + pad.x, 1., uv.x);
  float bottom = smoothstep(-pad.y, 0., uv.y);
  float top    = smoothstep(1. + pad.y, 1., uv.y);

  return left * right * bottom * top;
}

// Single-component CMYK extractors with contrast built-in, alpha-aware
float getCyan(vec4 rgba) {
  vec3 c = clamp((rgba.rgb - 0.5) * CONTRAST + 0.5, 0.0, 1.0);
  float maxRGB = max(max(c.r, c.g), c.b);
  return (maxRGB > 1e-5 ? (maxRGB - c.r) / maxRGB : 0.) * rgba.a;
}
float getMagenta(vec4 rgba) {
  vec3 c = clamp((rgba.rgb - 0.5) * CONTRAST + 0.5, 0.0, 1.0);
  float maxRGB = max(max(c.r, c.g), c.b);
  return (maxRGB > 1e-5 ? (maxRGB - c.g) / maxRGB : 0.) * rgba.a;
}
float getYellow(vec4 rgba) {
  vec3 c = clamp((rgba.rgb - 0.5) * CONTRAST + 0.5, 0.0, 1.0);
  float maxRGB = max(max(c.r, c.g), c.b);
  return (maxRGB > 1e-5 ? (maxRGB - c.b) / maxRGB : 0.) * rgba.a;
}
float getBlack(vec4 rgba) {
  vec3 c = clamp((rgba.rgb - 0.5) * CONTRAST + 0.5, 0.0, 1.0);
  return (1. - max(max(c.r, c.g), c.b)) * rgba.a;
}

vec2 cellCenterPos(vec2 uv, vec2 cellOffset, float channelIdx) {
  vec2 cellCenter = floor(uv) + .5 + cellOffset;
  return cellCenter + (randomRG(cellCenter + channelIdx * 50.) - .5) * GRID_NOISE;
}

vec2 gridToImageUV(vec2 cellCenter, float cosA, float sinA, float shift, vec2 pad) {
  vec2 uvGrid = mat2(cosA, -sinA, sinA, cosA) * (cellCenter - shift);
  return uvGrid * pad + 0.5;
}

// "ink" style (joined dots)
float colorMask(vec2 pos, vec2 cellCenter, float rad, float transparency, float grain, float flood, float gain, float generalComp) {
  float dist = length(pos - cellCenter);

  float radius = rad;
  radius *= (1. + generalComp);
  radius += (MIN_DOT + gain * radius);
  radius = max(0., radius);
  radius = mix(0., radius, transparency);
  radius += flood;
  radius *= (1. - grain);

  float mask = 1. - sst(0., radius, dist);
  mask = pow(mask, 1.2);

  mask *= mix(1., mix(.5, 1., 1.5 * radius), SOFTNESS);
  return mask;
}

vec3 applyInk(vec3 paper, vec3 inkColor, float cov) {
  vec3 inkEffect = mix(vec3(1.0), inkColor, clamp(cov, 0.0, 1.0));
  return paper * inkEffect;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / iResolution;
  float aspect = iResolution.x / iResolution.y;

  float cellsPerSide = mix(400.0, 7.0, pow(SIZE, 0.7));
  float cellSizeY = 1.0 / cellsPerSide;
  vec2 pad = cellSizeY * vec2(1.0 / aspect, 1.0);
  vec2 uvGrid = (uv - .5) / pad;
  float insideImageBox = getUvFrame(uv, pad);

  float generalComp = .1 * SOFTNESS + .1 * GRID_NOISE;

  vec2 uvC = mat2(cosC, sinC, -sinC, cosC) * uvGrid + shiftC;
  vec2 uvM = mat2(cosM, sinM, -sinM, cosM) * uvGrid + shiftM;
  vec2 uvY = mat2(cosY, sinY, -sinY, cosY) * uvGrid + shiftY;
  vec2 uvK = mat2(cosK, sinK, -sinK, cosK) * uvGrid + shiftK;

  vec2 grainSize = mix(2000., 200., GRAIN_SIZE) * vec2(1., 1. / aspect);
  vec2 grainUV = (uv - .5) * grainSize + .5;
  vec3 noiseValues = valueNoise3(grainUV);
  float grain = sst(.55, 1., noiseValues.r);
  grain *= GRAIN_MIXER;

  float C = 0.;
  float M = 0.;
  float Y = 0.;
  float K = 0.;

  // per-cell color sampling
  for (int dy = -1; dy <= 1; dy++) {
    for (int dx = -1; dx <= 1; dx++) {
      vec2 cellOffset = vec2(float(dx), float(dy));

      vec2 cellCenterC = cellCenterPos(uvC, cellOffset, 0.);
      vec4 texC = texture(u_image, gridToImageUV(cellCenterC, cosC, sinC, shiftC, pad));
      C += colorMask(uvC, cellCenterC, getCyan(texC), insideImageBox * texC.a, grain, FLOOD_C, GAIN_C, generalComp);

      vec2 cellCenterM = cellCenterPos(uvM, cellOffset, 1.);
      vec4 texM = texture(u_image, gridToImageUV(cellCenterM, cosM, sinM, shiftM, pad));
      M += colorMask(uvM, cellCenterM, getMagenta(texM), insideImageBox * texM.a, grain, FLOOD_M, GAIN_M, generalComp);

      vec2 cellCenterY = cellCenterPos(uvY, cellOffset, 2.);
      vec4 texY = texture(u_image, gridToImageUV(cellCenterY, cosY, sinY, shiftY, pad));
      Y += colorMask(uvY, cellCenterY, getYellow(texY), insideImageBox * texY.a, grain, FLOOD_Y, GAIN_Y, generalComp);

      vec2 cellCenterK = cellCenterPos(uvK, cellOffset, 3.);
      vec4 texK = texture(u_image, gridToImageUV(cellCenterK, cosK, sinK, shiftK, pad));
      K += colorMask(uvK, cellCenterK, getBlack(texK), insideImageBox * texK.a, grain, FLOOD_K, GAIN_K, generalComp);
    }
  }

  // ink style: apply threshold for joined dots
  // (fwidth is unavailable in Flutter fragment shaders, so a small constant
  // stands in for the derivative-based antialiasing of the original)
  float th = .5;
  float aa = .04;
  float sLeft = th * SOFTNESS;
  float sRight = (1. - th) * SOFTNESS + .01;
  C = smoothstep(th - sLeft - aa, th + sRight, C);
  M = smoothstep(th - sLeft - aa, th + sRight, M);
  Y = smoothstep(th - sLeft - aa, th + sRight, Y);
  K = smoothstep(th - sLeft - aa, th + sRight, K);

  C *= COLOR_C.a;
  M *= COLOR_M.a;
  Y *= COLOR_Y.a;
  K *= COLOR_K.a;

  vec3 ink = vec3(1.);
  ink = applyInk(ink, COLOR_K.rgb, K);
  ink = applyInk(ink, COLOR_C.rgb, C);
  ink = applyInk(ink, COLOR_M.rgb, M);
  ink = applyInk(ink, COLOR_Y.rgb, Y);

  float shape = clamp(max(max(C, M), max(Y, K)), 0., 1.);

  vec3 color = COLOR_BACK.rgb * COLOR_BACK.a;
  float opacity = COLOR_BACK.a;
  color = mix(color, ink, shape);
  opacity += shape;
  opacity = clamp(opacity, 0., 1.);

  float grainOverlay = mix(noiseValues.g, noiseValues.b, .5);
  grainOverlay = pow(grainOverlay, 1.3);

  float grainOverlayV = grainOverlay * 2. - 1.;
  vec3 grainOverlayColor = vec3(step(0., grainOverlayV));
  float grainOverlayStrength = GRAIN_OVERLAY * abs(grainOverlayV);
  grainOverlayStrength = pow(grainOverlayStrength, .8);
  color = mix(color, grainOverlayColor, .5 * grainOverlayStrength);

  opacity += .5 * grainOverlayStrength;
  opacity = clamp(opacity, 0., 1.);

  fragColor = vec4(color, opacity);
}
