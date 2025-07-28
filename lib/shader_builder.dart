import 'package:flutter/material.dart';
import 'dart:ui';

class ShaderMetadata {
  final String assetKey;
  final String name;
  final String url;
  final String author;
  final DateTime dateAdded;

  const ShaderMetadata({
    required this.assetKey,
    required this.name,
    required this.url,
    required this.author,
    required this.dateAdded,
  });
}

abstract class CustomShaderBuilder {
  const CustomShaderBuilder();

  /// Build the shader widget with the given metadata and optional child
  Widget buildShader(
    ShaderMetadata metadata,
    FragmentShader shader,
    Size size,
    double time,
    Widget? child,
  );

  /// Whether this shader requires an image sampler
  bool get requiresImageSampler => true;

  /// Duration of the animation in seconds (null means unbounded/infinite)
  Duration? get animationDuration => const Duration(milliseconds: 1800);

  /// Set shader uniforms
  void setUniforms(FragmentShader shader, Size size, double time);

  /// Build custom controls/configuration UI for this shader
  Widget buildControls(BuildContext context) {
    return const SizedBox.shrink();
  }
}
