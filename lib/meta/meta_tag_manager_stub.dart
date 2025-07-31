import 'meta_tag_manager_interface.dart';

/// Creates the stub implementation of meta tag manager for non-web platforms
MetaTagManagerInterface createMetaTagManager() {
  return MetaTagManagerStub();
}

/// Stub implementation for non-web platforms (desktop, mobile)
/// These platforms don't have HTML meta tags, so this is a no-op implementation
class MetaTagManagerStub implements MetaTagManagerInterface {
  static const String baseUrl = 'https://roszkowski.dev/shaders_gallery';

  @override
  void updateForShader({
    required String shaderName,
    required String shaderTitle,
    required String description,
    required String author,
    required String imageUrl,
    String? sourceUrl,
  }) {
    // No-op on non-web platforms
    // Desktop and mobile apps don't have HTML meta tags to update
  }

  @override
  void updateForHomePage() {
    // No-op on non-web platforms
    // Desktop and mobile apps don't have HTML meta tags to update
  }

  @override
  String getShaderImageUrl(String shaderPath) {
    // Return the same URL structure for consistency
    final imageName = '${shaderPath.replaceAll('-', '_')}.png';
    return '$baseUrl/assets/screenshots/$imageName';
  }
}
