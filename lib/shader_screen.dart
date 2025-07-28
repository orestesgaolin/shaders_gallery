import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:shaders/tv_test_screen.dart';

import 'main.dart';

class ShaderScreen extends StatefulWidget {
  const ShaderScreen({
    super.key,
    required this.shaderInfo,
  });

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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _controller
      ..forward()
      ..repeat(reverse: true);
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
        return ShaderBuilder(
          assetKey: widget.shaderInfo.assetKey,
          (context, shader, _) {
            return AnimatedSampler(
              (image, size, canvas) {
                final animation = TweenSequence<double>([
                  TweenSequenceItem(
                    tween: Tween<double>(begin: 0.0, end: 1.0)
                        .chain(CurveTween(curve: Curves.easeInOut)),
                    weight: 50.0,
                  ),
                  TweenSequenceItem(
                    tween: Tween<double>(begin: 1.0, end: 0.0)
                        .chain(CurveTween(curve: Curves.easeInOut)),
                    weight: 50.0,
                  ),
                ]).animate(_controller);
                widget.shaderInfo.config
                    .setUniforms(shader, size, animation.value);
                shader.setImageSampler(0, image);

                canvas.drawRect(
                  Rect.fromLTWH(0, 0, size.width, size.height),
                  Paint()..shader = shader,
                );
              },
              child: child!,
            );
          },
        );
      },
      child: const Center(
        child: TvTestScreen(),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shaderInfo.name),
        centerTitle: true,
      ),
      body: shaderView,
    );
  }
}
