import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:shaders/tv_test_screen.dart';
import 'dart:ui';
import 'shader_builder.dart';

class NtscShaderBuilder extends CustomShaderBuilder {
  const NtscShaderBuilder();

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
    return AnimatedSampler((image, size, canvas) {
      if (requiresImageSampler) {
        shader.setImageSampler(0, image);
      }
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..shader = shader,
      );
    }, child: child ?? const SizedBox());
  }

  @override
  Widget? childBuilder(BuildContext context) {
    return const Center(child: TvTestScreen());
  }
}
