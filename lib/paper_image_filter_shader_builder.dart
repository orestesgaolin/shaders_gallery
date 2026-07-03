import 'dart:async';
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

  /// The shaders hardcode 3 samplers and IMAGE_CYCLE_SECONDS = 6; keep this
  /// list length and the cycle in sync with them.
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
    final image = frame.image;
    // Convert to raw pixels so the engine can never lazily re-decode the
    // JPEG mid-animation (a source of frame drops, especially on web)
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) {
      return image;
    }
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      byteData.buffer.asUint8List(),
      image.width,
      image.height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
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
    // All images stay bound on fixed samplers; the shader rotates between
    // them based on iTime, so no binding ever changes mid-animation
    for (var i = 0; i < images.length; i++) {
      shader
        ..setFloat(3 + i, images[i].width / images[i].height)
        ..setImageSampler(i, images[i]);
    }
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
