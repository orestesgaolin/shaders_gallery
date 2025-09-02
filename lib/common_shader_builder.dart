import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'shader_builder.dart';

class CommonShaderBuilder extends CustomShaderBuilder {
  const CommonShaderBuilder({this.enableMouse = false});

  final bool enableMouse;

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
    var animatedSampler = AnimatedSampler(
      (image, size, canvas) {
        if (requiresImageSampler) {
          shader.setImageSampler(0, image);
        }
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Paint()..shader = shader,
        );
      },
      child: child ?? const SizedBox.expand(),
    );
    if (enableMouse) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        onPanUpdate: (details) {
          shader
            ..setFloat(3, details.localPosition.dx)
            ..setFloat(4, size.height - details.localPosition.dy);
        },
        child: animatedSampler,
      );
    }
    return animatedSampler;
  }

  @override
  Widget? childBuilder(BuildContext context) {
    return null;
  }
}
