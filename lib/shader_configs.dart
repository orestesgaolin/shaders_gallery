import 'dart:ui';


abstract class ShaderConfig {
  const ShaderConfig();

  void setUniforms(FragmentShader shader, Size size, double time);
}
