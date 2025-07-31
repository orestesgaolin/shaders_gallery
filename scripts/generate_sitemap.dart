#!/usr/bin/env dart

import 'dart:io';

/// Generates sitemap.xml for the shader gallery
void main() async {
  print('🗺️  Generating sitemap.xml for Shader Gallery...');

  const baseUrl = 'https://roszkowski.dev/shaders_gallery';
  const currentDate = '2025-07-30'; // Update this to current date

  // Define all shader paths (matching your ShaderInfo list)
  final shaderPaths = [
    'ntsc-shader',
    'crt-shader',
    'noise-shader',
    'noise-overlay-shader',
    'rings-shader',
    'clearly-bug-shader',
  ];

  // Build sitemap XML
  final sitemap = StringBuffer();
  sitemap.writeln('<?xml version="1.0" encoding="UTF-8"?>');
  sitemap.writeln('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">');

  // Add home page
  sitemap.writeln('  <url>');
  sitemap.writeln('    <loc>$baseUrl/</loc>');
  sitemap.writeln('    <lastmod>$currentDate</lastmod>');
  sitemap.writeln('    <changefreq>weekly</changefreq>');
  sitemap.writeln('    <priority>1.0</priority>');
  sitemap.writeln('  </url>');

  // Add shader pages
  for (final shaderPath in shaderPaths) {
    sitemap.writeln('  <url>');
    sitemap.writeln('    <loc>$baseUrl/shader/$shaderPath</loc>');
    sitemap.writeln('    <lastmod>$currentDate</lastmod>');
    sitemap.writeln('    <changefreq>monthly</changefreq>');
    sitemap.writeln('    <priority>0.8</priority>');
    sitemap.writeln('  </url>');
  }

  sitemap.writeln('</urlset>');

  // Write to web directory (will be copied to build during build process)
  final sitemapFile = File('web/sitemap.xml');
  await sitemapFile.writeAsString(sitemap.toString());

  print('✅ Sitemap generated: ${sitemapFile.path}');
  print('📄 Includes ${shaderPaths.length + 1} URLs (home + shaders)');

  // Also create robots.txt
  final robotsTxt =
      '''User-agent: *
Allow: /

# Sitemap
Sitemap: $baseUrl/sitemap.xml

# Specific pages to index
Allow: /shader/

# Disallow paths that don't exist
Disallow: *.dart
Disallow: /flutter_assets/
Disallow: /canvaskit/
''';

  final robotsFile = File('web/robots.txt');
  await robotsFile.writeAsString(robotsTxt);

  print('✅ Robots.txt generated: ${robotsFile.path}');
}
