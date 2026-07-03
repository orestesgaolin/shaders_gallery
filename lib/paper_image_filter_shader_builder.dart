import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import 'shader_builder.dart';
import 'widgets/cycling_image_content.dart';

/// Builder for paper.design image-filter shaders (Image Dithering, Water).
/// Feeds a cycling set of images to the shader via [AnimatedSampler] and sets
/// the standard resolution + time uniforms.
class PaperImageFilterShaderBuilder extends CustomShaderBuilder {
  const PaperImageFilterShaderBuilder({
    this.imageInterval = const Duration(seconds: 6),
  });

  final Duration imageInterval;

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
    return AnimatedSampler(
      (image, size, canvas) {
        shader.setImageSampler(0, image);
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Paint()..shader = shader,
        );
      },
      child: child ?? const SizedBox.expand(),
    );
  }

  @override
  Widget? childBuilder(BuildContext context) => CyclingImageContent(interval: imageInterval);
}
