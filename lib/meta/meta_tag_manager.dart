import 'meta_tag_manager_interface.dart';
import 'meta_tag_manager_stub.dart'
    if (dart.library.html) 'meta_tag_manager_web.dart'
    if (dart.library.js_interop) 'meta_tag_manager_web.dart';

/// Factory class that provides the appropriate meta tag manager based on platform
class MetaTagManager {
  static MetaTagManagerInterface? _instance;

  /// Get the platform-appropriate meta tag manager instance
  static MetaTagManagerInterface get instance {
    _instance ??= createMetaTagManager();
    return _instance!;
  }

  /// Updates the page title and meta tags for a specific shader
  static void updateForShader({
    required String shaderName,
    required String shaderTitle,
    required String description,
    required String author,
    required String imageUrl,
    String? sourceUrl,
  }) {
    instance.updateForShader(
      shaderName: shaderName,
      shaderTitle: shaderTitle,
      description: description,
      author: author,
      imageUrl: imageUrl,
      sourceUrl: sourceUrl,
    );
  }

  /// Updates meta tags for the home page
  static void updateForHomePage() {
    instance.updateForHomePage();
  }

  /// Generates the image URL for a shader screenshot
  static String getShaderImageUrl(String shaderPath) {
    return instance.getShaderImageUrl(shaderPath);
  }
}
