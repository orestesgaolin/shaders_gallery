import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'shader_builder.dart';

class NoiseOverlayShaderBuilder extends CustomShaderBuilder {
  const NoiseOverlayShaderBuilder();

  @override
  bool get requiresImageSampler => true;

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
    return NoiseShaderOverlayWidget(
      shader: shader,
      child: child,
    );
  }

  @override
  Widget? childBuilder(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          color: Colors.blue,

          child: SizedBox(
            width: 300,
            height: 200,
          ),
        ),
      ),
    );
  }
}

class NoiseShaderOverlayWidget extends StatefulWidget {
  const NoiseShaderOverlayWidget({
    super.key,
    required this.shader,
    this.child,
  });

  final FragmentShader shader;
  final Widget? child;

  @override
  State<NoiseShaderOverlayWidget> createState() => _NoiseShaderOverlayWidgetState();
}

class _NoiseShaderOverlayWidgetState extends State<NoiseShaderOverlayWidget> {
  double intensity = 0.2;

  @override
  void initState() {
    super.initState();
    widget.shader.setFloat(2, intensity);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedSampler(
          (image, size, canvas) {
            widget.shader.setImageSampler(0, image);
            canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..shader = widget.shader);
          },

          child: widget.child ?? const SizedBox(),
        ),
        Center(
          child: Text(
            'Noise',
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
        Positioned(
          bottom: 0,left: 0, right: 0,
          child: Row(
            children: [
              Expanded(
                child: Slider(
                  value: intensity,
                  min: 0,
                  max: 1,
                  onChanged: (value) {
                    setState(() {
                      intensity = value;
                      widget.shader.setFloat(2, intensity);
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
        ),
      ],
    );
  }
}
