import 'dart:ui';
import 'shader_configs.dart';

class NoiseOverlayShaderConfig extends ShaderConfig {
  final double filmGrainIntensity;
  final double noiseOpacity;

  const NoiseOverlayShaderConfig({
    this.filmGrainIntensity = 0.1,
    this.noiseOpacity = 0.3,
  });

  @override
  bool get requiresImageSampler => true;

  @override
  Duration? get animationDuration => null; // Unbounded animation

  @override
  void setUniforms(FragmentShader shader, Size size, double time) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time)
      ..setFloat(3, filmGrainIntensity)
      ..setFloat(4, noiseOpacity);
  }
}
