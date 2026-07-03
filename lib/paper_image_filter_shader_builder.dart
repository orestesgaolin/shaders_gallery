import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'shader_builder.dart';

/// Builder for paper.design image-filter shaders (Image Dithering, Water).
///
/// Decodes a set of images once and binds the current and next one directly
/// as shader textures; the cover-fit and crossfade happen inside the shader.
/// This avoids re-rasterizing a widget subtree with AnimatedSampler on every
/// frame, keeping the per-frame cost to a single fullscreen quad.
class PaperImageFilterShaderBuilder extends CustomShaderBuilder {
  const PaperImageFilterShaderBuilder();

  /// Must match IMAGE_CYCLE_SECONDS in the shaders.
  static const _cycleSeconds = 6.0;

  static const _assetKeys = [
    'assets/images/starry_night.jpg',
    'assets/images/pearl_earring.jpg',
    'assets/images/great_wave.jpg',
  ];

  static List<ui.Image>? _images;
  static Future<List<ui.Image>>? _future;

  static Future<ui.Image> _decode(String key) async {
    final data = await rootBundle.load(key);
    final buffer = await ui.ImmutableBuffer.fromUint8List(data.buffer.asUint8List());
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final codec = await descriptor.instantiateCodec();
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  bool get requiresImageSampler => false;

  @override
  Duration? get animationDuration => null; // Unbounded animation

  @override
  void setUniforms(ui.FragmentShader shader, Size size, double time) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time);
  }

  @override
  Widget buildShader(
    ShaderMetadata metadata,
    ui.FragmentShader shader,
    Size size,
    double time,
    Widget? child,
  ) {
    final images = _images;
    if (images == null) {
      _future ??= Future.wait(_assetKeys.map(_decode)).then((list) => _images = list);
      return FutureBuilder<List<ui.Image>>(
        future: _future,
        builder: (context, snapshot) {
          final loaded = snapshot.data;
          if (loaded == null) {
            return const SizedBox.expand();
          }
          return _paint(shader, time, loaded);
        },
      );
    }
    return _paint(shader, time, images);
  }

  Widget _paint(ui.FragmentShader shader, double time, List<ui.Image> images) {
    final index = (time / _cycleSeconds).floor() % images.length;
    final current = images[index];
    final upcoming = images[(index + 1) % images.length];
    shader
      ..setFloat(3, current.width / current.height)
      ..setFloat(4, upcoming.width / upcoming.height)
      ..setImageSampler(0, current)
      ..setImageSampler(1, upcoming);
    return SizedBox.expand(
      child: CustomPaint(painter: _ShaderQuadPainter(shader, time)),
    );
  }

  @override
  Widget? childBuilder(BuildContext context) => null;
}

class _ShaderQuadPainter extends CustomPainter {
  _ShaderQuadPainter(this.shader, this.time);

  final ui.FragmentShader shader;
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_ShaderQuadPainter oldDelegate) => oldDelegate.time != time;
}
