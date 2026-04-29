import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'dart:ui';
import 'shader_builder.dart';

class MeshParticlesShaderBuilder extends CustomShaderBuilder {
  const MeshParticlesShaderBuilder();

  @override
  bool get requiresImageSampler => false;

  @override
  Duration? get animationDuration => null;

  @override
  void setUniforms(FragmentShader shader, Size size, double time) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time);
  }

  @override
  Widget buildShader(
    ShaderMetadata metadata,
    FragmentShader shader,
    Size size,
    double time,
    Widget? child,
  ) {
    return CustomPaint(
      size: Size.infinite,
      painter: _MeshParticlesPainter(time: time),
    );
  }

  @override
  Widget? childBuilder(BuildContext context) => null;
}

class _MeshParticlesPainter extends CustomPainter {
  final double time;
  _MeshParticlesPainter({required this.time});

  static const int particleCount = 4096;
  static const int _seg = 12;
  static const int _vpp = 1 + 2 * _seg;
  static const int _ipp = _seg * 3 + _seg * 6;
  static const int _batchSize = 2048;
  static const double _innerR = 0.8;

  static final Float64List _pRadius = Float64List(particleCount);
  static final Float64List _pAngle = Float64List(particleCount);
  static final Float64List _pSpeed = Float64List(particleCount);
  static final Float64List _pSize = Float64List(particleCount);
  static final Float64List _pHue = Float64List(particleCount);
  static final Float64List _pAlpha = Float64List(particleCount);
  static final Float64List _pPhase = Float64List(particleCount);

  static final Float64List _sCos = Float64List.fromList(
    List.generate(_seg, (i) => cos(i / _seg * 2 * pi)),
  );
  static final Float64List _sSin = Float64List.fromList(
    List.generate(_seg, (i) => sin(i / _seg * 2 * pi)),
  );

  static final Uint16List _batchIdx = _buildBatchIndices(_batchSize);
  static final Float32List _pos = Float32List(_batchSize * _vpp * 2);
  static final Int32List _col = Int32List(_batchSize * _vpp);

  static bool _initialized = false;

  static void _init() {
    if (_initialized) return;
    _initialized = true;
    final rng = Random(1337);
    for (var i = 0; i < particleCount; i++) {
      _pRadius[i] = 0.05 + rng.nextDouble() * 0.95;
      _pAngle[i] = rng.nextDouble() * 2 * pi;
      _pSpeed[i] = 0.12 + rng.nextDouble() * 0.62;
      _pSize[i] = 6.0 + pow(rng.nextDouble(), 1.7).toDouble() * 30.0;
      _pHue[i] = 0.53 + rng.nextDouble() * 0.36;
      _pAlpha[i] = 0.16 + rng.nextDouble() * 0.52;
      _pPhase[i] = rng.nextDouble() * 2 * pi;
    }
  }

  static Uint16List _buildBatchIndices(int count) {
    final idx = Uint16List(count * _ipp);
    var ii = 0;
    for (var p = 0; p < count; p++) {
      final b = p * _vpp;
      for (var s = 0; s < _seg; s++) {
        final s1 = (s + 1) % _seg;
        idx[ii++] = b;
        idx[ii++] = b + 1 + s;
        idx[ii++] = b + 1 + s1;
        idx[ii++] = b + 1 + s;
        idx[ii++] = b + 1 + _seg + s;
        idx[ii++] = b + 1 + _seg + s1;
        idx[ii++] = b + 1 + s;
        idx[ii++] = b + 1 + _seg + s1;
        idx[ii++] = b + 1 + s1;
      }
    }
    return idx;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _init();
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF080E18),
    );
    _drawGrid(canvas, size);
    _drawParticles(canvas, size);
  }

  void _drawParticles(Canvas canvas, Size size) {
    final t = time;
    final w = size.width;
    final h = size.height;
    final minSide = w < h ? w : h;
    final halfW = w * 0.5;
    final halfH = h * 0.5;
    final paint = Paint()..blendMode = BlendMode.plus;

    for (var batch = 0; batch < particleCount; batch += _batchSize) {
      final batchEnd = min(batch + _batchSize, particleCount);
      final count = batchEnd - batch;
      var vi = 0;
      var pidx = 0;

      for (var p = batch; p < batchEnd; p++) {
        final phase = _pPhase[p];
        final spd = _pSpeed[p];
        final angle = _pAngle[p] + t * spd;
        final orbit = _pRadius[p] * minSide * 0.46;
        final wobble = sin(phase + t * 1.37) * minSide * 0.045;
        final curl = cos(phase * 0.71 + t * 0.91) * minSide * 0.035;
        final pcx = halfW +
            cos(angle) * (orbit + wobble) +
            cos(angle * 2.13 + phase) * curl;
        final pcy = halfH +
            sin(angle * 0.86 + phase * 0.11) * (orbit + wobble) +
            sin(angle * 1.61 - phase) * curl;

        final pulse = 0.74 + 0.26 * sin(t * 2.2 + phase);
        final sz = _pSize[p] * pulse;

        final vAlpha = _pAlpha[p] * (0.78 + 0.22 * sin(t * 1.7 + phase));
        final vPhase = phase + t * spd;
        final sparkle = 0.5 + 0.5 * sin(vPhase * 3.0 + t * 4.2);

        final coreA = (vAlpha * (1.07 + sparkle * 0.08)).clamp(0.0, 1.0);
        final ringA = (vAlpha * (0.72 + sparkle * 0.08)).clamp(0.0, 1.0);

        final rgb = _hsv2rgb(_pHue[p] + t * 0.015, 0.76, 1.0);
        final r = rgb[0], g = rgb[1], b = rgb[2];
        final centerColor = _packArgb(r, g, b, coreA);
        final innerColor = _packArgb(r, g, b, ringA);

        _pos[pidx++] = pcx;
        _pos[pidx++] = pcy;
        _col[vi++] = centerColor;

        final innerSz = sz * _innerR;
        for (var s = 0; s < _seg; s++) {
          _pos[pidx++] = pcx + _sCos[s] * innerSz;
          _pos[pidx++] = pcy + _sSin[s] * innerSz;
          _col[vi++] = innerColor;
        }
        for (var s = 0; s < _seg; s++) {
          _pos[pidx++] = pcx + _sCos[s] * sz;
          _pos[pidx++] = pcy + _sSin[s] * sz;
          _col[vi++] = 0;
        }
      }

      final vertCount = count * _vpp;
      final idxCount = count * _ipp;

      final vertices = ui.Vertices.raw(
        VertexMode.triangles,
        Float32List.sublistView(_pos, 0, vertCount * 2),
        colors: Int32List.sublistView(_col, 0, vertCount),
        indices: count == _batchSize
            ? _batchIdx
            : Uint16List.sublistView(_batchIdx, 0, idxCount),
      );

      canvas.drawVertices(vertices, BlendMode.src, paint);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    const grid = 12;
    final stepX = size.width / grid;
    final stepY = size.height / grid;
    final gridPaint = Paint()
      ..color = const Color.fromARGB(36, 120, 156, 196)
      ..strokeWidth = 1;
    final borderPaint = Paint()
      ..color = const Color.fromARGB(80, 120, 156, 196)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (var i = 0; i <= grid; i++) {
      final x = (i * stepX).roundToDouble() + 0.5;
      final y = (i * stepY).roundToDouble() + 0.5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.drawRect(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      borderPaint,
    );
  }

  static final Float64List _rgbBuf = Float64List(3);

  static Float64List _hsv2rgb(double h, double s, double v) {
    h = h % 1.0;
    if (h < 0) h += 1.0;
    final c = v * s;
    final x = c * (1.0 - ((h * 6.0) % 2.0 - 1.0).abs());
    final m = v - c;
    switch ((h * 6.0).floor() % 6) {
      case 0:
        _rgbBuf[0] = c + m; _rgbBuf[1] = x + m; _rgbBuf[2] = m;
      case 1:
        _rgbBuf[0] = x + m; _rgbBuf[1] = c + m; _rgbBuf[2] = m;
      case 2:
        _rgbBuf[0] = m; _rgbBuf[1] = c + m; _rgbBuf[2] = x + m;
      case 3:
        _rgbBuf[0] = m; _rgbBuf[1] = x + m; _rgbBuf[2] = c + m;
      case 4:
        _rgbBuf[0] = x + m; _rgbBuf[1] = m; _rgbBuf[2] = c + m;
      default:
        _rgbBuf[0] = c + m; _rgbBuf[1] = m; _rgbBuf[2] = x + m;
    }
    return _rgbBuf;
  }

  static int _packArgb(double r, double g, double b, double a) {
    return ((a * 255).round().clamp(0, 255) << 24) |
        ((r * 255).round().clamp(0, 255) << 16) |
        ((g * 255).round().clamp(0, 255) << 8) |
        (b * 255).round().clamp(0, 255);
  }

  @override
  bool shouldRepaint(_MeshParticlesPainter old) => true;
}
