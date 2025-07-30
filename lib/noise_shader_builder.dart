import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'shader_builder.dart';

class NoiseShaderBuilder extends CustomShaderBuilder {
  const NoiseShaderBuilder();

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
    // ..setFloat(3, filmGrainIntensity);
  }

  @override
  Widget buildShader(
    ShaderMetadata metadata,
    FragmentShader shader,
    Size size,
    double time,
    Widget? child,
  ) {
    return NoiseShaderWidget(
      shader: shader,
    );
  }

  @override
  Widget? childBuilder(BuildContext context) {
    return null;
  }
}

class NoiseShaderWidget extends StatefulWidget {
  const NoiseShaderWidget({
    super.key,
    required this.shader,
  });

  final FragmentShader shader;

  @override
  State<NoiseShaderWidget> createState() => _NoiseShaderWidgetState();
}

class _NoiseShaderWidgetState extends State<NoiseShaderWidget> {
  double intensity = 0.1;

  @override
  void initState() {
    super.initState();
    widget.shader.setFloat(3, intensity);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            size: Size.infinite,
            painter: _NoiseShaderPainter(widget.shader),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: intensity,
                min: 0,
                max: 1,
                onChanged: (value) {
                  setState(() {
                    intensity = value;
                    widget.shader.setFloat(3, intensity);
                  });
                },
              ),
            ),
            Text(
              'Intensity: ${intensity.toStringAsFixed(2)}',
              style: GoogleFonts.spaceMono(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
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
