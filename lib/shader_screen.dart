import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:shaders/tv_test_screen.dart';

import 'main.dart';

class ShaderScreen extends StatefulWidget {
  const ShaderScreen({super.key, required this.shaderInfo});

  final ShaderInfo shaderInfo;

  @override
  State<ShaderScreen> createState() => _ShaderScreenState();
}

class _ShaderScreenState extends State<ShaderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final duration = widget.shaderInfo.config.animationDuration;

    if (duration != null) {
      // Bounded animation
      _controller = AnimationController(vsync: this, duration: duration);
      _controller
        ..forward()
        ..repeat(reverse: true);
    } else {
      // Unbounded animation - use a long duration and repeat without reverse
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(
          seconds: 3600,
        ), // 1 hour cycle for continuous time
      );
      _controller
        ..forward()
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shaderView = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderBuilder(assetKey: widget.shaderInfo.assetKey, (
          context,
          shader,
          _,
        ) {
          return AnimatedSampler((image, size, canvas) {
            final duration = widget.shaderInfo.config.animationDuration;
            double timeValue;

            if (duration != null) {
              // Bounded animation - use animated value between 0-1
              final animation = TweenSequence<double>([
                TweenSequenceItem(
                  tween: Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).chain(CurveTween(curve: Curves.easeInOut)),
                  weight: 50.0,
                ),
                TweenSequenceItem(
                  tween: Tween<double>(
                    begin: 1.0,
                    end: 0.0,
                  ).chain(CurveTween(curve: Curves.easeInOut)),
                  weight: 50.0,
                ),
              ]).animate(_controller);
              timeValue = animation.value;
            } else {
              // Unbounded animation - use controller value as continuous time
              // Scale the 0-1 controller value to actual time in seconds
              timeValue = _controller.value * _controller.duration!.inSeconds;
            }

            widget.shaderInfo.config.setUniforms(shader, size, timeValue);

            // Only set image sampler if the shader requires it
            if (widget.shaderInfo.config.requiresImageSampler) {
              shader.setImageSampler(0, image);
            }

            canvas.drawRect(
              Rect.fromLTWH(0, 0, size.width, size.height),
              Paint()..shader = shader,
            );
          }, child: child!);
        });
      },
      child: const Center(child: TvTestScreen()),
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.shaderInfo.name), centerTitle: true),
      body: shaderView,
    );
  }
}
