import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import 'paper_noise_texture.dart';
import 'shader_builder.dart';

class PaperTextureShaderBuilder extends CustomShaderBuilder {
  const PaperTextureShaderBuilder();

  @override
  bool get requiresImageSampler => false;

  @override
  Duration? get animationDuration => null; // Unbounded animation

  @override
  void setUniforms(FragmentShader shader, Size size, double time) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time);
  }

  @override
  Widget buildShader(
    ShaderMetadata metadata,
    FragmentShader shader,
    Size size,
    double time,
    Widget? child,
  ) {
    return withPaperNoiseTexture(
      (noise) => AnimatedSampler(
        (image, size, canvas) {
          shader.setImageSampler(0, noise);
          canvas.drawRect(
            Rect.fromLTWH(0, 0, size.width, size.height),
            Paint()..shader = shader,
          );
        },
        child: child ?? const SizedBox.expand(),
      ),
    );
  }

  @override
  Widget? childBuilder(BuildContext context) => null;
}
