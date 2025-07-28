import 'dart:ui';
import 'shader_configs.dart';

class NoiseShaderConfig extends ShaderConfig {
  final double filmGrainIntensity;

  const NoiseShaderConfig({this.filmGrainIntensity = 0.1});

  @override
  bool get requiresImageSampler => false;

  @override
  Duration? get animationDuration => null; // Unbounded animation

  @override
  void setUniforms(FragmentShader shader, Size size, double time) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time)
      ..setFloat(3, filmGrainIntensity);
  }
}
