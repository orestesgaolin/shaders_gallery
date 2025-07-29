import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'dart:ui';
import 'shader_builder.dart';

class NoiseOverlayShaderBuilder extends CustomShaderBuilder {
  final double filmGrainIntensity;
  final double noiseOpacity;

  const NoiseOverlayShaderBuilder({
    this.filmGrainIntensity = 0.2,
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
      ..setFloat(2, filmGrainIntensity);
  }

  @override
  Widget buildShader(
    ShaderMetadata metadata,
    FragmentShader shader,
    Size size,
    double time,
    Widget? child,
  ) {
    return Stack(
      children: [
        AnimatedSampler(
          (image, size, canvas) {
            shader.setImageSampler(0, image);
            canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..shader = shader);
          },

          child: child ?? const SizedBox(),
        ),
        Center(
          child: Text(
            'Noise',
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget? childBuilder(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          color: Colors.blue,

          child: SizedBox(
            width: 300,
            height: 200,
          ),
        ),
      ),
    );
  }
}
