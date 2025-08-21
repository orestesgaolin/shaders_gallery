import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'dart:ui';
import 'shader_builder.dart';
import 'package:flutter/scheduler.dart';

class DistortedMotionShaderBuilder extends CustomShaderBuilder {
  const DistortedMotionShaderBuilder();

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
    return _ShaderWidget(shader: shader);
  }

  @override
  Widget? childBuilder(BuildContext context) {
    return null;
  }
}

class _ShaderWidget extends StatefulWidget {
  final FragmentShader shader;

  const _ShaderWidget({required this.shader});

  @override
  State<_ShaderWidget> createState() => _ShaderWidgetState();
}

class _ShaderWidgetState extends State<_ShaderWidget> with TickerProviderStateMixin {
  final scrollController = ScrollController();
  final ValueNotifier<double> _velocity = ValueNotifier(0);
  Ticker? _ticker;
  double _lastPosition = 0.0;
  double _smoothedVelocity = 0.0;
  static const double alpha = 0.1; // Smoothing factor
  int _seed = 0;

  @override
  void initState() {
    super.initState();
    _seed = DateTime.now().second;
    widget.shader.setFloat(3, 0.0); // Initial velocity y
    _ticker = createTicker((_) {
      if (scrollController.hasClients) {
        final newPosition = scrollController.position.pixels;
        final velocity = newPosition - _lastPosition;
        _smoothedVelocity = (alpha * velocity) + (1.0 - alpha) * _smoothedVelocity;
        _lastPosition = newPosition;
        _velocity.value = _smoothedVelocity;
        widget.shader.setFloat(3, _smoothedVelocity);
      }
    });
    _ticker?.start();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var listView = NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          // The velocity is calculated in the ticker for smoothness.
        }
        return true;
      },
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 32),

        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: index.isEven ? Colors.blue : Colors.red,
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage('https://picsum.photos/id/${index % 5 + _seed}/600/200'),
                  fit: BoxFit.cover,
                ),
              ),
              // child: Image.network(
              //   'https://picsum.photos/id/${index % 5 + _seed}/600/200',
              //   fit: BoxFit.cover,
              // ),
            ),
          );
        },
      ),
    );
    return Stack(
      children: [
        AnimatedSampler(
          (image, size, canvas) {
            widget.shader.setImageSampler(0, image);
            canvas.drawRect(
              Rect.fromLTWH(0, 0, size.width, size.height),
              Paint()..shader = widget.shader,
            );
          },
          child: listView,
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: ValueListenableBuilder(
            valueListenable: _velocity,
            builder: (context, value, child) {
              return Text('Velocity: ${value.toStringAsFixed(2)}');
            },
          ),
        ),
      ],
    );
  }
}
