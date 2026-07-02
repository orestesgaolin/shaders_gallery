import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

ui.Image? _noiseImage;
Future<ui.Image>? _noiseFuture;

Future<ui.Image> _loadNoiseTexture() async {
  final data = await rootBundle.load('assets/textures/paper_noise.png');
  final buffer = await ui.ImmutableBuffer.fromUint8List(data.buffer.asUint8List());
  final descriptor = await ui.ImageDescriptor.encoded(buffer);
  final codec = await descriptor.instantiateCodec();
  final frame = await codec.getNextFrame();
  return frame.image;
}

/// Builds [builder] once the pre-computed randomizer texture shared by the
/// paper.design shaders is loaded. The texture is decoded once and cached.
Widget withPaperNoiseTexture(Widget Function(ui.Image noise) builder) {
  final image = _noiseImage;
  if (image != null) {
    return builder(image);
  }
  _noiseFuture ??= _loadNoiseTexture().then((img) => _noiseImage = img);
  return FutureBuilder<ui.Image>(
    future: _noiseFuture,
    builder: (context, snapshot) {
      final img = snapshot.data;
      if (img == null) {
        return const SizedBox.expand();
      }
      return builder(img);
    },
  );
}
