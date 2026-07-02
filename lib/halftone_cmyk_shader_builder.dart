import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import 'paper_noise_texture.dart';
import 'shader_builder.dart';

class HalftoneCmykShaderBuilder extends CustomShaderBuilder {
  const HalftoneCmykShaderBuilder();

  @override
  Duration? get animationDuration => null; // Unbounded animation

  @override
  void setUniforms(FragmentShader shader, Size size, double time) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height);
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
          shader.setImageSampler(0, image);
          shader.setImageSampler(1, noise);
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
  Widget? childBuilder(BuildContext context) => const HalftoneDemoContent();
}

/// Colorful animated content for the halftone filter to print.
class HalftoneDemoContent extends StatefulWidget {
  const HalftoneDemoContent({super.key});

  @override
  State<HalftoneDemoContent> createState() => _HalftoneDemoContentState();
}

class _HalftoneDemoContentState extends State<HalftoneDemoContent> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GradientBlobsPainter(_controller.value),
          child: child,
        );
      },
      child: const Center(
        child: Text(
          'CMYK',
          style: TextStyle(
            fontSize: 120,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1a1a1a),
            letterSpacing: 8,
          ),
        ),
      ),
    );
  }
}

class _GradientBlobsPainter extends CustomPainter {
  _GradientBlobsPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    final a = t * 2 * math.pi;
    final radius = size.shortestSide * 0.55;

    void blob(double cx, double cy, Color color) {
      final center = Offset(cx * size.width, cy * size.height);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }

    blob(
      0.25 + 0.15 * math.sin(a),
      0.35 + 0.12 * math.cos(a),
      const Color(0xFFE53935),
    );
    blob(
      0.75 + 0.12 * math.sin(a + 2.1),
      0.30 + 0.15 * math.cos(a + 2.1),
      const Color(0xFF1E88E5),
    );
    blob(
      0.50 + 0.18 * math.sin(a + 4.2),
      0.72 + 0.10 * math.cos(a + 4.2),
      const Color(0xFF43A047),
    );
    blob(
      0.30 + 0.10 * math.sin(a + 1.0),
      0.80 + 0.12 * math.cos(a + 3.0),
      const Color(0xFFFB8C00),
    );
  }

  @override
  bool shouldRepaint(_GradientBlobsPainter oldDelegate) => oldDelegate.t != t;
}
