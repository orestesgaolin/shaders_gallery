import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import '../main.dart';

/// A widget that handles the animation and rendering of a shader.
///
/// This widget manages the animation controller and coordinates with the shader builder
/// to render the shader effect with proper timing and animation handling.
class ShaderAnimationView extends StatefulWidget {
  final ShaderInfo shaderInfo;

  const ShaderAnimationView({
    super.key,
    required this.shaderInfo,
  });

  @override
  State<ShaderAnimationView> createState() => _ShaderAnimationViewState();
}

class _ShaderAnimationViewState extends State<ShaderAnimationView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final duration = widget.shaderInfo.builder.animationDuration;

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
        duration: const Duration(seconds: 3600), // 1 hour cycle for continuous time
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
    return LayoutBuilder(
      builder: (context, size) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ShaderBuilder(
              assetKey: widget.shaderInfo.assetKey,
              (context, shader, _) {
                final duration = widget.shaderInfo.builder.animationDuration;
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

                widget.shaderInfo.builder.setUniforms(shader, size.biggest, timeValue);

                return widget.shaderInfo.builder.buildShader(
                  widget.shaderInfo.metadata,
                  shader,
                  size.biggest,
                  timeValue,
                  widget.shaderInfo.builder.childBuilder(context),
                );
              },
            );
          },
        );
      },
    );
  }
}
