import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
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
  Widget buildControls(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NTSC Shader Controls',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('An effect that emulates an old NTSC television signal.'),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.tv, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                const Text('Effect: NTSC TV Signal'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.repeat, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                const Text('Animation: Bounded (loops with reverse)'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
