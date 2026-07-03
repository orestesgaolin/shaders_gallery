#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

// Water by paper.design (https://shaders.paper.design)
// Ported to Flutter from https://github.com/paper-design/shaders (MIT)
// Water-like surface distortion with caustic realism, applied to the widget
// rendered behind it. Parameter values below match the "Default" preset
// on shaders.paper.design.

uniform vec2 iResolution;
uniform float iTime;
uniform sampler2D u_image;

out vec4 fragColor;

const vec4 COLOR_BACK = vec4(0.565, 0.565, 0.565, 1.0);      // #909090
const vec4 COLOR_HIGHLIGHT = vec4(1.0, 1.0, 1.0, 1.0);       // #ffffff
const float HIGHLIGHTS = 0.07;
const float LAYERING = 0.5;
const float EDGES = 0.8;
const float WAVES = 0.3;
const float CAUSTIC = 0.1;
const float SIZE = 1.0;

#define TWO_PI 6.28318530718
#define PI 3.14159265358979323846

vec3 permute(vec3 x) { return mod(((x * 34.0) + 1.0) * x, 289.0); }
float snoise(vec2 v) {
  const vec4 C = vec4(0.211324865405187, 0.366025403784439,
    -0.577350269189626, 0.024390243902439);
  vec2 i = floor(v + dot(v, C.yy));
  vec2 x0 = v - i + dot(i, C.xx);
  vec2 i1;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = mod(i, 289.0);
  vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0))
    + i.x + vec3(0.0, i1.x, 1.0));
  vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy),
      dot(x12.zw, x12.zw)), 0.0);
  m = m * m;
  m = m * m;
  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;
  m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
  vec3 g;
  g.x = a0.x * x0.x + h.x * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

float getUvFrame(vec2 uv) {
  // fwidth is unavailable in Flutter fragment shaders; the UV spans the
  // canvas, so one pixel is 1/resolution in UV space
  float aax = 2. / iResolution.x;
  float aay = 2. / iResolution.y;

  float left   = smoothstep(0., aax, uv.x);
  float right = 1.0 - smoothstep(1. - aax, 1., uv.x);
  float bottom = smoothstep(0., aay, uv.y);
  float top = 1.0 - smoothstep(1. - aay, 1., uv.y);

  return left * right * bottom * top;
}

mat2 rotate2D(float r) {
  return mat2(cos(r), sin(r), -sin(r), cos(r));
}

float getCausticNoise(vec2 uv, float t, float scale) {
  vec2 n = vec2(.1);
  vec2 N = vec2(.1);
  mat2 m = rotate2D(.5);
  for (int j = 0; j < 6; j++) {
    uv *= m;
    n *= m;
    vec2 q = uv * scale + float(j) + n + (.5 + .5 * float(j)) * (mod(float(j), 2.) - 1.) * t;
    n += sin(q);
    N += cos(q) / scale;
    scale *= 1.1;
  }
  return (N.x + N.y + 1.);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / iResolution;
  float aspect = iResolution.x / iResolution.y;

  vec2 imageUV = uv;
  vec2 patternUV = uv - .5;
  patternUV = (patternUV * vec2(aspect, 1.));
  patternUV /= (.01 + .09 * SIZE);

  float t = iTime;

  float wavesNoise = snoise((.3 + .1 * sin(t)) * .1 * patternUV + vec2(0., .4 * t));

  float causticNoise = getCausticNoise(patternUV + WAVES * vec2(1., -1.) * wavesNoise, 2. * t, 1.5);

  causticNoise += LAYERING * getCausticNoise(patternUV + 2. * WAVES * vec2(1., -1.) * wavesNoise, 1.5 * t, 2.);
  causticNoise = causticNoise * causticNoise;

  float edgesDistortion = smoothstep(0., .1, imageUV.x);
  edgesDistortion *= smoothstep(0., .1, imageUV.y);
  edgesDistortion *= (smoothstep(1., 1.1, imageUV.x) + (1.0 - smoothstep(.8, .95, imageUV.x)));
  edgesDistortion *= (1.0 - smoothstep(.9, 1., imageUV.y));
  edgesDistortion = mix(edgesDistortion, 1., EDGES);

  float causticNoiseDistortion = .02 * causticNoise * edgesDistortion;

  float wavesDistortion = .1 * WAVES * wavesNoise;

  imageUV += vec2(wavesDistortion, -wavesDistortion);
  imageUV += (CAUSTIC * causticNoiseDistortion);

  float frame = getUvFrame(imageUV);

  vec4 image = texture(u_image, imageUV);
  vec4 backColor = COLOR_BACK;
  backColor.rgb *= backColor.a;

  vec3 color = mix(backColor.rgb, image.rgb, image.a * frame);
  float opacity = backColor.a + image.a * frame;

  causticNoise = max(-.2, causticNoise);

  float highlight = .025 * HIGHLIGHTS * causticNoise;
  highlight *= COLOR_HIGHLIGHT.a;
  color = mix(color, COLOR_HIGHLIGHT.rgb, .05 * HIGHLIGHTS * causticNoise);
  opacity += highlight;

  color += highlight * (.5 + .5 * wavesNoise);
  opacity += highlight * (.5 + .5 * wavesNoise);

  opacity = clamp(opacity, 0., 1.);

  fragColor = vec4(color, opacity);
}
