import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'dart:ui';
import 'shader_builder.dart';

class NoiseOverlayShaderBuilder extends CustomShaderBuilder {
  final double filmGrainIntensity;
  final double noiseOpacity;

  const NoiseOverlayShaderBuilder({
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

  @override
  Widget buildShader(
    ShaderMetadata metadata,
    FragmentShader shader,
    Size size,
    double time,
    Widget? child,
  ) {
    return AnimatedSampler((image, size, canvas) {
      shader.setImageSampler(0, image);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..shader = shader,
      );
    }, child: child ?? const SizedBox());
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
              'Noise Overlay Controls',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Applies animated noise effect as an overlay on content'),
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
                Icon(Icons.opacity, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Text('Opacity: ${(noiseOpacity * 100).toInt()}%'),
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
