import 'package:flutter/material.dart';
import 'package:shaders/shader_source_viewer.dart';
import '../main.dart';

/// A tabbed panel that displays shader controls and source code.
/// 
/// This widget provides two tabs:
/// - Controls: Custom shader-specific controls built by the shader builder
/// - Source: The shader source code with syntax highlighting and copy functionality
class ShaderControlPanel extends StatelessWidget {
  final ShaderInfo shaderInfo;

  const ShaderControlPanel({
    super.key,
    required this.shaderInfo,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.settings), text: 'Controls'),
              Tab(icon: Icon(Icons.code), text: 'Source'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: shaderInfo.builder.buildControls(context),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ShaderSourceViewer(
                    assetKey: shaderInfo.assetKey,
                    shaderName: shaderInfo.name,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
