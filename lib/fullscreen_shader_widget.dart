import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'main.dart';

/// A widget that displays a shader in full screen for screenshot purposes
class FullscreenShaderWidget extends StatefulWidget {
  final ShaderInfo shaderInfo;

  const FullscreenShaderWidget({
    super.key,
    required this.shaderInfo,
  });

  @override
  State<FullscreenShaderWidget> createState() => _FullscreenShaderWidgetState();
}

class _FullscreenShaderWidgetState extends State<FullscreenShaderWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final duration = widget.shaderInfo.builder.animationDuration;

    if (duration != null) {
      // Bounded animation
      _controller = AnimationController(vsync: this, duration: duration);
      _controller.forward();
    } else {
      // Unbounded animation - use a long duration
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3600),
      );
      _controller.forward();
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
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ShaderBuilder(
              assetKey: widget.shaderInfo.assetKey,
              (context, shader, _) {
                final duration = widget.shaderInfo.builder.animationDuration;
                double timeValue;

                if (duration != null) {
                  // Bounded animation - use a simple normalized value
                  timeValue = _controller.value;
                } else {
                  // Unbounded animation - use controller value as continuous time
                  timeValue = _controller.value * _controller.duration!.inSeconds;
                }

                widget.shaderInfo.builder.setUniforms(shader, constraints.biggest, timeValue);

                return SizedBox.expand(
                  child: widget.shaderInfo.builder.buildShader(
                    widget.shaderInfo.metadata,
                    shader,
                    constraints.biggest,
                    timeValue,
                    widget.shaderInfo.builder.childBuilder(context),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
