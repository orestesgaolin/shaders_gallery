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
  const PaperImageFilterShaderBuilder({this.continuous = false});

  /// Whether the shader animates every frame (water) or only changes at
  /// dither-type boundaries and during image crossfades (dithering). For
  /// non-continuous shaders the time uniform is held between visual changes
  /// so the painter skips repainting frames that would look identical.
  final bool continuous;

  static const _typeCycleSeconds = 3.0;
  static const _imageCycleSeconds = 6.0;
  static const _imageFadeSeconds = 0.7;

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

  /// Time quantized to the last visual change: continuous during the fade
  /// window, otherwise held at the last dither-type boundary.
  double _effectiveTime(double time) {
    if (continuous) {
      return time;
    }
    final cyclePos = time % _imageCycleSeconds;
    if (cyclePos > _imageCycleSeconds - _imageFadeSeconds - 0.05) {
      return time;
    }
    return (time / _typeCycleSeconds).floorToDouble() * _typeCycleSeconds;
  }

  @override
  void setUniforms(ui.FragmentShader shader, Size size, double time) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, _effectiveTime(time));
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
    return SizedBox.expand(
      child: CustomPaint(
        painter: _ShaderQuadPainter(shader, _effectiveTime(time), images),
      ),
    );
  }

  @override
  Widget? childBuilder(BuildContext context) => null;
}

class _ShaderQuadPainter extends CustomPainter {
  _ShaderQuadPainter(this.shader, this.time, this.images);

  final ui.FragmentShader shader;
  final double time;
  final List<ui.Image> images;

  @override
  void paint(Canvas canvas, Size size) {
    // Samplers are (re)bound here rather than at build time: paint runs only
    // when the effective time actually changed (shouldRepaint below), so the
    // per-frame sampler-wrapper garbage that caused GC frame drops is gone,
    // while every real repaint still gets fresh bindings — required on the
    // web engine, where bindings don't reliably survive across frames.
    for (var i = 0; i < images.length; i++) {
      shader
        ..setFloat(3 + i, images[i].width / images[i].height)
        ..setImageSampler(i, images[i]);
    }
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_ShaderQuadPainter oldDelegate) => oldDelegate.time != time;
}
