import 'dart:ui';
import 'shader_configs.dart';

class NtscShaderConfig extends ShaderConfig {
  const NtscShaderConfig();

  @override
  void setUniforms(FragmentShader shader, Size size, double time) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time);
  }
}
