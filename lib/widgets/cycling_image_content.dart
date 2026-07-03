import 'dart:async';

import 'package:flutter/material.dart';

/// Cycles through a set of public-domain artworks with a crossfade,
/// providing varied content for image-filter shaders to process.
class CyclingImageContent extends StatefulWidget {
  const CyclingImageContent({
    super.key,
    this.interval = const Duration(seconds: 6),
  });

  final Duration interval;

  static const images = [
    'assets/images/starry_night.jpg',
    'assets/images/pearl_earring.jpg',
    'assets/images/great_wave.jpg',
  ];

  @override
  State<CyclingImageContent> createState() => _CyclingImageContentState();
}

class _CyclingImageContentState extends State<CyclingImageContent> {
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.interval, (_) {
      setState(() {
        _index = (_index + 1) % CyclingImageContent.images.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 700),
      child: Image.asset(
        CyclingImageContent.images[_index],
        key: ValueKey(_index),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
