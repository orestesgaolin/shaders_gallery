/// Base interface for meta tag management across platforms
abstract class MetaTagManagerInterface {
  /// Updates the page title and meta tags for a specific shader
  void updateForShader({
    required String shaderName,
    required String shaderTitle,
    required String description,
    required String author,
    required String imageUrl,
    String? sourceUrl,
  });

  /// Updates meta tags for the home page
  void updateForHomePage();

  /// Generates the image URL for a shader screenshot
  String getShaderImageUrl(String shaderPath);
}
