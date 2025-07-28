import 'dart:ui';

abstract class ShaderConfig {
  const ShaderConfig();

  void setUniforms(FragmentShader shader, Size size, double time);

  // Whether this shader requires an image sampler
  bool get requiresImageSampler => true;

  // Duration of the animation in seconds (null means unbounded/infinite)
  Duration? get animationDuration => const Duration(milliseconds: 1800);
}
