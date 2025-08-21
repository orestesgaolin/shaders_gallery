import 'package:flutter/material.dart';
import 'dart:ui';
import 'shader_builder.dart';

class AiAssistantShaderBuilder extends CustomShaderBuilder {
  const AiAssistantShaderBuilder();

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
    return ClipRect(
      child: CustomPaint(
        size: Size.infinite,
        painter: _AiAssistantShaderPainter(shader),
      ),
    );
  }

  @override
  Widget? childBuilder(BuildContext context) {
    return null;
  }
}

class _AiAssistantShaderPainter extends CustomPainter {
  final FragmentShader shader;

  _AiAssistantShaderPainter(this.shader);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
