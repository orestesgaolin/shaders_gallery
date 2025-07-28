#!/usr/bin/env dart

import 'dart:io';
import 'dart:async';

/// Script to copy shader files from shaders/ directory to assets/shaders/
/// This allows the shader source code to be viewed in the app
Future<void> main() async {
  print('🔧 Copying shader files to assets directory...');
  
  final shaderDir = Directory('shaders');
  final assetsShaderDir = Directory('assets/shaders');
  
  // Ensure assets/shaders directory exists
  if (!await assetsShaderDir.exists()) {
    await assetsShaderDir.create(recursive: true);
    print('📁 Created assets/shaders directory');
  }
  
  // Get all .frag files from shaders directory
  final shaderFiles = await shaderDir
      .list()
      .where((entity) => entity is File && entity.path.endsWith('.frag'))
      .cast<File>()
      .toList();
  
  if (shaderFiles.isEmpty) {
    print('⚠️  No shader files found in shaders/ directory');
    return;
  }
  
  // Copy each shader file to assets/shaders
  for (final shaderFile in shaderFiles) {
    final fileName = shaderFile.path.split('/').last;
    final targetFile = File('assets/shaders/$fileName');
    
    await shaderFile.copy(targetFile.path);
    print('✅ Copied $fileName to assets/shaders/');
  }
  
  print('🎉 Successfully copied ${shaderFiles.length} shader files!');
}
