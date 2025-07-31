import 'package:web/web.dart' as web;
import 'meta_tag_manager_interface.dart';

/// Creates the web implementation of meta tag manager
MetaTagManagerInterface createMetaTagManager() {
  return MetaTagManagerWeb();
}

/// Web implementation of meta tag management using package:web
class MetaTagManagerWeb implements MetaTagManagerInterface {
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
    final fullUrl = '$baseUrl/shader/$shaderName';
    final fullTitle = '$shaderTitle - Flutter Shader Gallery';
    final fullDescription = '$description by $author. Interactive GLSL shader gallery.';

    // Update page title
    web.document.title = fullTitle;

    // Update basic meta tags
    _updateMetaTag('description', fullDescription);
    _updateMetaTag('keywords', 'shader, flutter, GLSL, $shaderName, $author, webgl, interactive, graphics');

    // Update OpenGraph tags
    _updateMetaProperty('og:url', fullUrl);
    _updateMetaProperty('og:title', fullTitle);
    _updateMetaProperty('og:description', fullDescription);
    _updateMetaProperty('og:image', imageUrl);
    _updateMetaProperty('og:type', 'article');

    // Update Twitter Card tags
    _updateMetaProperty('twitter:card', 'summary_large_image');
    _updateMetaProperty('twitter:url', fullUrl);
    _updateMetaProperty('twitter:title', fullTitle);
    _updateMetaProperty('twitter:description', fullDescription);
    _updateMetaProperty('twitter:image', imageUrl);

    // Add article-specific tags
    _updateMetaProperty('article:author', author);
    if (sourceUrl != null) {
      _updateMetaProperty('article:section', 'Shaders');
      _addCanonicalLink(sourceUrl);
    }
  }

  @override
  void updateForHomePage() {
    const title = 'Flutter Shader Gallery';
    const description = 'A collection of shaders made to work with Flutter';
    const url = '$baseUrl/';
    const imageUrl = '$baseUrl/assets/screenshots/preview.jpeg';

    // Update page title
    web.document.title = title;

    // Update basic meta tags
    _updateMetaTag('description', description);
    _updateMetaTag('keywords', 'shaders, flutter, GLSL, graphics, webgl, interactive, gallery');

    // Update OpenGraph tags
    _updateMetaProperty('og:url', url);
    _updateMetaProperty('og:title', title);
    _updateMetaProperty('og:description', description);
    _updateMetaProperty('og:image', imageUrl);
    _updateMetaProperty('og:type', 'website');

    // Update Twitter Card tags
    _updateMetaProperty('twitter:card', 'summary_large_image');
    _updateMetaProperty('twitter:url', url);
    _updateMetaProperty('twitter:title', title);
    _updateMetaProperty('twitter:description', description);
    _updateMetaProperty('twitter:image', imageUrl);

    // Remove any article-specific tags
    _removeMetaProperty('article:author');
    _removeMetaProperty('article:section');
    _removeCanonicalLink();
  }

  @override
  String getShaderImageUrl(String shaderPath) {
    // Convert shader path to image filename
    final imageName = '${shaderPath.replaceAll('-', '_')}.png';
    return '$baseUrl/assets/screenshots/$imageName';
  }

  /// Updates or creates a meta tag with name attribute
  void _updateMetaTag(String name, String content) {
    final existing = web.document.querySelector('meta[name="$name"]');
    if (existing != null) {
      existing.setAttribute('content', content);
    } else {
      final meta = web.document.createElement('meta');
      meta.setAttribute('name', name);
      meta.setAttribute('content', content);
      web.document.head!.appendChild(meta);
    }
  }

  /// Updates or creates a meta tag with property attribute (for OpenGraph)
  void _updateMetaProperty(String property, String content) {
    final existing = web.document.querySelector('meta[property="$property"]');
    if (existing != null) {
      existing.setAttribute('content', content);
    } else {
      final meta = web.document.createElement('meta');
      meta.setAttribute('property', property);
      meta.setAttribute('content', content);
      web.document.head!.appendChild(meta);
    }
  }

  /// Removes a meta tag with property attribute
  void _removeMetaProperty(String property) {
    final existing = web.document.querySelector('meta[property="$property"]');
    existing?.remove();
  }

  /// Adds or updates canonical link
  void _addCanonicalLink(String url) {
    final existing = web.document.querySelector('link[rel="canonical"]');
    if (existing != null) {
      existing.setAttribute('href', url);
    } else {
      final link = web.document.createElement('link');
      link.setAttribute('rel', 'canonical');
      link.setAttribute('href', url);
      web.document.head!.appendChild(link);
    }
  }

  /// Removes canonical link
  void _removeCanonicalLink() {
    final existing = web.document.querySelector('link[rel="canonical"]');
    existing?.remove();
  }
}
