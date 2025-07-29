import 'package:flutter/material.dart';
import 'dart:ui';
import 'shader_builder.dart';

class RingsShaderBuilder extends CustomShaderBuilder {
  const RingsShaderBuilder();

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
      ..setFloat(3, 0.5);
    // ..setFloat(4, size.width * 0.5) // Default interaction point X (center)
    // ..setFloat(5, size.height * 0.5); // Default interaction point Y (center)
  }

  @override
  Widget buildShader(
    ShaderMetadata metadata,
    FragmentShader shader,
    Size size,
    double time,
    Widget? child,
  ) {
    return _InteractiveRingsWidget(shader: shader);
  }

  @override
  Widget? childBuilder(BuildContext context) {
    return null;
  }
}

class _InteractiveRingsWidget extends StatefulWidget {
  final FragmentShader shader;

  const _InteractiveRingsWidget({required this.shader});

  @override
  State<_InteractiveRingsWidget> createState() => _InteractiveRingsWidgetState();
}

class _InteractiveRingsWidgetState extends State<_InteractiveRingsWidget> {
  double _mouseX = 0.0;
  double _mouseY = 0.0;
  double _interactionStrength = 2.0;

  void _updateInteraction(double x, double y, double strength) {
    setState(() {
      _mouseX = x;
      _mouseY = y;
      _interactionStrength = strength;
    });
    widget.shader
      ..setFloat(3, strength)
      ..setFloat(4, x)
      ..setFloat(5, y);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTapDown: (details) {
            _updateInteraction(details.localPosition.dx, details.localPosition.dy, 1.0);
          },
          onTapUp: (_) {
            _updateInteraction(_mouseX, _mouseY, 0.5);
          },
          onPanUpdate: (details) {
            _updateInteraction(details.localPosition.dx, details.localPosition.dy, 0.8);
          },
          onPanEnd: (_) {
            _updateInteraction(_mouseX, _mouseY, 0.5);
          },
          child: CustomPaint(
            size: Size.infinite,
            painter: _RingsShaderPainter(widget.shader),
          ),
        ),
        // Debug text overlay
        // Positioned(
        //   left: 16,
        //   bottom: 16,
        //   child: Container(
        //     padding: const EdgeInsets.all(8),
        //     decoration: BoxDecoration(
        //       color: Colors.black54,
        //       borderRadius: BorderRadius.circular(4),
        //     ),
        //     child: Text(
        //       'Mouse: (${_mouseX.toStringAsFixed(1)}, ${_mouseY.toStringAsFixed(1)})\n'
        //       'Strength: ${_interactionStrength.toStringAsFixed(2)}',
        //       style: const TextStyle(
        //         color: Colors.white,
        //         fontSize: 12,
        //         fontFamily: 'monospace',
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

class _RingsShaderPainter extends CustomPainter {
  final FragmentShader shader;

  _RingsShaderPainter(this.shader);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
