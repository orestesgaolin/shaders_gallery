import 'package:flutter/material.dart';
import 'widgets/widgets.dart';
import 'main.dart';

/// The main screen for displaying and interacting with a specific shader.
/// 
/// This screen has been refactored to use composable widgets:
/// - ResponsiveShaderLayout: Handles responsive layout adaptation
/// - ShaderInfoDialog: Shows detailed shader information
/// 
/// The screen is now much simpler and delegates responsibility to specialized widgets.
class ShaderScreen extends StatelessWidget {
  const ShaderScreen({super.key, required this.shaderInfo});

  final ShaderInfo shaderInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shaderInfo.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => ShaderInfoDialog.show(context, shaderInfo),
          ),
        ],
      ),
      body: ResponsiveShaderLayout(shaderInfo: shaderInfo),
    );
  }
}
