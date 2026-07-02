#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

// Paper Texture by paper.design (https://shaders.paper.design)
// Ported to Flutter from https://github.com/paper-design/shaders (MIT)
// A static texture built from multiple noise layers, usable for realistic
// paper and cardboard surfaces. Parameter values below match the "Default"
// preset on shaders.paper.design; the seed drifts slowly with time.

uniform vec2 iResolution;
uniform float iTime;
uniform sampler2D u_noiseTexture;

out vec4 fragColor;

const vec4 COLOR_FRONT = vec4(0.624, 0.678, 0.737, 1.0); // #9fadbc
const vec4 COLOR_BACK = vec4(1.0, 1.0, 1.0, 1.0);        // #ffffff
const float CONTRAST = 0.3;
const float ROUGHNESS = 0.4;
const float FIBER = 0.3;
const float FIBER_SIZE = 0.2;
const float CRUMPLES = 0.3;
const float CRUMPLE_SIZE = 0.35;
const float FOLDS = 0.65;
const float FOLD_COUNT = 5.0;
const float FADE = 0.0;
const float DROPS = 0.2;
const float SEED = 5.8;
const float SCALE = 0.6;

#define TWO_PI 6.28318530718
#define PI 3.14159265358979323846

vec2 rotate(vec2 uv, float th) {
  return mat2(cos(th), sin(th), -sin(th), cos(th)) * uv;
}

float randomR(vec2 p) {
  vec2 uv = floor(p) / 100. + .5;
  return texture(u_noiseTexture, fract(uv)).r;
}

float valueNoise(vec2 st) {
  vec2 i = floor(st);
  vec2 f = fract(st);
  float a = randomR(i);
  float b = randomR(i + vec2(1.0, 0.0));
  float c = randomR(i + vec2(0.0, 1.0));
  float d = randomR(i + vec2(1.0, 1.0));
  vec2 u = f * f * (3.0 - 2.0 * f);
  float x1 = mix(a, b, u.x);
  float x2 = mix(c, d, u.x);
  return mix(x1, x2, u.y);
}

float fbm(vec2 n) {
  float total = 0.0, amplitude = .4;
  for (int i = 0; i < 3; i++) {
    total += valueNoise(n) * amplitude;
    n *= 1.99;
    amplitude *= 0.65;
  }
  return total;
}

float randomG(vec2 p) {
  vec2 uv = floor(p) / 50. + .5;
  return texture(u_noiseTexture, fract(uv)).g;
}

float roughness(vec2 p) {
  p *= .1;
  float o = 0.;
  for (float i = 1.; i < 4.; i++) {
    vec4 w = vec4(floor(p), ceil(p));
    vec2 f = fract(p);
    o += mix(
    mix(randomG(w.xy), randomG(w.xw), f.y),
    mix(randomG(w.zy), randomG(w.zw), f.y),
    f.x);
    o += .2 / exp(2. * abs(sin(.2 * p.x + .5 * p.y)));
    p *= 2.1;
  }
  return o / 3.;
}

float fiberRandom(vec2 p) {
  vec2 uv = floor(p) / 100.;
  return texture(u_noiseTexture, fract(uv)).b;
}

float fiberValueNoise(vec2 st) {
  vec2 i = floor(st);
  vec2 f = fract(st);
  float a = fiberRandom(i);
  float b = fiberRandom(i + vec2(1.0, 0.0));
  float c = fiberRandom(i + vec2(0.0, 1.0));
  float d = fiberRandom(i + vec2(1.0, 1.0));
  vec2 u = f * f * (3.0 - 2.0 * f);
  float x1 = mix(a, b, u.x);
  float x2 = mix(c, d, u.x);
  return mix(x1, x2, u.y);
}

float fiberNoiseFbm(in vec2 n, vec2 seedOffset) {
  float total = 0.0, amplitude = 1.;
  for (int i = 0; i < 4; i++) {
    n = rotate(n, .7);
    total += fiberValueNoise(n + seedOffset) * amplitude;
    n *= 2.;
    amplitude *= 0.6;
  }
  return total;
}

float fiberNoise(vec2 uv, vec2 seedOffset) {
  float epsilon = 0.001;
  float n1 = fiberNoiseFbm(uv + vec2(epsilon, 0.0), seedOffset);
  float n2 = fiberNoiseFbm(uv - vec2(epsilon, 0.0), seedOffset);
  float n3 = fiberNoiseFbm(uv + vec2(0.0, epsilon), seedOffset);
  float n4 = fiberNoiseFbm(uv - vec2(0.0, epsilon), seedOffset);
  return length(vec2(n1 - n2, n3 - n4)) / (2.0 * epsilon);
}

vec2 randomGB(vec2 p) {
  vec2 uv = floor(p) / 50. + .5;
  return texture(u_noiseTexture, fract(uv)).gb;
}

float crumpledNoise(vec2 t, float pw) {
  vec2 p = floor(t);
  float wsum = 0.;
  float cl = 0.;
  for (int y = -1; y < 2; y += 1) {
    for (int x = -1; x < 2; x += 1) {
      vec2 b = vec2(float(x), float(y));
      vec2 q = b + p;
      vec2 q2 = q - floor(q / 8.) * 8.;
      vec2 c = q + randomGB(q2);
      vec2 r = c - t;
      float w = pow(smoothstep(0., 1., 1. - abs(r.x)), pw) * pow(smoothstep(0., 1., 1. - abs(r.y)), pw);
      cl += (.5 + .5 * sin((q2.x + q2.y * 5.) * 8.)) * w;
      wsum += w;
    }
  }
  return pow(wsum != 0.0 ? cl / wsum : 0.0, .5) * 2.;
}

float crumplesShape(vec2 uv) {
  return crumpledNoise(uv * .25, 16.) * crumpledNoise(uv * .5, 2.);
}

vec2 folds(vec2 uv, float seed) {
  vec3 pp = vec3(0.);
  float l = 9.;
  for (float i = 0.; i < FOLD_COUNT; i++) {
    vec2 rand = randomGB(vec2(i, i * seed));
    float an = rand.x * TWO_PI;
    vec2 p = vec2(cos(an), sin(an)) * rand.y;
    float dist = distance(uv, p);
    l = min(l, dist);

    if (l == dist) {
      pp.xy = (uv - p.xy);
      pp.z = dist;
    }
  }
  return mix(pp.xy, vec2(0.), pow(pp.z, .25));
}

float drops(vec2 uv, float seed) {
  vec2 iDropsUV = floor(uv);
  vec2 fDropsUV = fract(uv);
  float dropsMinDist = 1.;
  for (int j = -1; j <= 1; j++) {
    for (int i = -1; i <= 1; i++) {
      vec2 neighbor = vec2(float(i), float(j));
      vec2 offset = randomGB(iDropsUV + neighbor);
      offset = .5 + .5 * sin(10. * seed + TWO_PI * offset);
      vec2 pos = neighbor + offset - fDropsUV;
      float dist = length(pos);
      dropsMinDist = min(dropsMinDist, dropsMinDist * dist);
    }
  }
  return 1. - smoothstep(.05, .09, pow(dropsMinDist, .5));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / iResolution;
  float aspect = iResolution.x / iResolution.y;

  // A slowly drifting seed makes the folds rotate and the speckles wander
  float seed = SEED + .02 * iTime;

  vec2 patternUV = uv - .5;
  patternUV = 5. * patternUV * vec2(aspect, 1.) / SCALE;

  vec2 roughnessUv = 1.5 * (fragCoord - .5 * iResolution);
  float roughnessVal = roughness(roughnessUv + vec2(1., 0.)) - roughness(roughnessUv - vec2(1., 0.));

  vec2 crumplesUV = fract(patternUV * .02 / CRUMPLE_SIZE - seed) * 32.;
  float crumples = CRUMPLES * (crumplesShape(crumplesUV + vec2(.05, 0.)) - crumplesShape(crumplesUV));

  vec2 fiberUV = 2. / FIBER_SIZE * patternUV;
  float fiber = fiberNoise(fiberUV, vec2(0.));
  fiber = .5 * FIBER * (fiber - 1.);

  vec2 normal = vec2(0.);

  vec2 foldsUV = patternUV * .12;
  foldsUV = rotate(foldsUV, 4. * seed);
  vec2 w = folds(foldsUV, seed);
  foldsUV = rotate(foldsUV + .007 * cos(seed), .01 * sin(seed));
  vec2 w2 = folds(foldsUV, seed);

  float dropsVal = DROPS * drops(patternUV * 2., seed);

  float fade = FADE * fbm(.17 * patternUV + 10. * seed);
  fade = clamp(8. * fade * fade * fade, 0., 1.);

  w = mix(w, vec2(0.), fade);
  w2 = mix(w2, vec2(0.), fade);
  crumples = mix(crumples, 0., fade);
  dropsVal = mix(dropsVal, 0., fade);
  fiber *= mix(1., .5, fade);
  roughnessVal *= mix(1., .5, fade);

  normal += FOLDS * min(5. * CONTRAST, 1.) * 4. * max(vec2(0.), w + w2);
  normal += crumples;
  normal += 3. * dropsVal;
  normal += ROUGHNESS * 1.5 * roughnessVal;
  normal += fiber;

  vec3 lightPos = vec3(1., 2., 1.);
  float res = dot(normalize(vec3(normal, 9.5 - 9. * pow(CONTRAST, .1))), normalize(lightPos));

  vec3 fgColor = COLOR_FRONT.rgb * COLOR_FRONT.a;
  float fgOpacity = COLOR_FRONT.a;
  vec3 bgColor = COLOR_BACK.rgb * COLOR_BACK.a;
  float bgOpacity = COLOR_BACK.a;

  vec3 color = fgColor * res;
  float opacity = fgOpacity * res;

  color += bgColor * (1. - opacity);
  opacity += bgOpacity * (1. - opacity);

  color -= .007 * dropsVal;

  fragColor = vec4(color, opacity);
}
