import 'package:flutter/material.dart';
import 'dart:ui';
import 'shader_builder.dart';

class NoiseShaderBuilder extends CustomShaderBuilder {
  final double filmGrainIntensity;

  const NoiseShaderBuilder({this.filmGrainIntensity = 0.1});

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

  @override
  Widget buildShader(
    ShaderMetadata metadata,
    FragmentShader shader,
    Size size,
    double time,
    Widget? child,
  ) {
    return CustomPaint(
      size: Size.infinite,
      painter: _NoiseShaderPainter(shader),
    );
  }

  @override
  Widget buildControls(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Noise Shader Controls',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Animated gradient noise with film grain effect'),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.grain, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Text('Film Grain: ${(filmGrainIntensity * 100).toInt()}%'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.all_inclusive, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                const Text('Animation: Continuous'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NoiseShaderPainter extends CustomPainter {
  final FragmentShader shader;

  _NoiseShaderPainter(this.shader);

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
