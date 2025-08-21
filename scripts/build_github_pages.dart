#!/usr/bin/env dart

import 'dart:io';

/// Build script for deploying Flutter web app to GitHub Pages
/// This handles the SPA routing configuration needed for GitHub Pages
void main(List<String> args) async {
  const baseHref = '/shaders_gallery/';

  // Check if we should build in release mode (default for CI)
  final isRelease =
      args.contains('--release') || Platform.environment['CI'] == 'true' || args.isEmpty; // Default to release if no args provided

  print('🚀 Building Flutter web app for GitHub Pages...');
  print('📍 Base href: $baseHref');
  print('🏗️  Build mode: ${isRelease ? 'release' : 'debug'}');

  // Build the Flutter web app
  final buildArgs = [
    'build',
    'web',
    '--base-href=$baseHref',
    if (isRelease) '--release',
    '--wasm'
  ];

  final buildResult = await Process.run(
    'flutter',
    buildArgs,
    workingDirectory: Directory.current.path,
  );

  if (buildResult.exitCode != 0) {
    print('❌ Flutter build failed:');
    print(buildResult.stderr);
    exit(1);
  }

  print('✅ Flutter build completed successfully');

  // Copy 404.html to build directory
  print('📄 Copying 404.html to build directory...');
  final source404 = File('web/404.html');
  final dest404 = File('build/web/404.html');

  if (await source404.exists()) {
    await source404.copy(dest404.path);
    print('✅ 404.html copied successfully');
  } else {
    print('⚠️  Warning: web/404.html not found');
  }

  // Copy sitemap.xml to build directory
  print('📄 Copying sitemap.xml to build directory...');
  final sourceSitemap = File('web/sitemap.xml');
  final destSitemap = File('build/web/sitemap.xml');

  if (await sourceSitemap.exists()) {
    await sourceSitemap.copy(destSitemap.path);
    print('✅ sitemap.xml copied successfully');
  } else {
    print('⚠️  Warning: web/sitemap.xml not found');
  }

  // Copy robots.txt to build directory
  print('📄 Copying robots.txt to build directory...');
  final sourceRobots = File('web/robots.txt');
  final destRobots = File('build/web/robots.txt');

  if (await sourceRobots.exists()) {
    await sourceRobots.copy(destRobots.path);
    print('✅ robots.txt copied successfully');
  } else {
    print('⚠️  Warning: web/robots.txt not found');
  }

  // Create .nojekyll file
  print('📄 Creating .nojekyll file...');
  final nojekyll = File('build/web/.nojekyll');
  await nojekyll.writeAsString('');
  print('✅ .nojekyll file created');

  print('');
  print('🎉 Build complete! Files in build/web/ are ready for deployment.');
  print('');
  print('📋 Deployment instructions:');
  print('1. Copy all files from build/web/ to your GitHub Pages repository');
  print('2. Ensure repository settings point to the correct branch/folder');
  print('3. Your site will be available at: https://roszkowski.dev$baseHref');
  print('');
  print('🔗 Test URLs that should work after deployment:');
  print('   • https://roszkowski.dev$baseHref');
  print('   • https://roszkowski.dev${baseHref}shader/noise-overlay-shader');
  print('   • https://roszkowski.dev${baseHref}shader/crt-shader');
}
