import 'package:flutter/material.dart';
import 'shader_animation_view.dart';
import 'shader_control_panel.dart';
import '../main.dart';

/// A responsive layout that adapts the shader view based on screen size.
///
/// On wide screens (>800px), displays the shader animation and controls side by side.
/// On narrow screens, stacks them vertically with the animation on top.
class ResponsiveShaderLayout extends StatelessWidget {
  final ShaderInfo shaderInfo;

  const ResponsiveShaderLayout({super.key, required this.shaderInfo});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 800;

        if (isWideScreen) {
          return _WideScreenLayout(shaderInfo: shaderInfo);
        } else {
          return _NarrowScreenLayout(shaderInfo: shaderInfo);
        }
      },
    );
  }
}

class _WideScreenLayout extends StatelessWidget {
  final ShaderInfo shaderInfo;

  const _WideScreenLayout({required this.shaderInfo});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 1, child: ShaderAnimationView(shaderInfo: shaderInfo)),
        const VerticalDivider(width: 1),
        Expanded(flex: 1, child: ShaderControlPanel(shaderInfo: shaderInfo)),
      ],
    );
  }
}

class _NarrowScreenLayout extends StatelessWidget {
  final ShaderInfo shaderInfo;

  const _NarrowScreenLayout({required this.shaderInfo});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final shaderViewHeight =
        screenHeight * 0.4; // 40% of screen height for shader view
    final controlPanelHeight =
        screenHeight * 0.6; // 60% of screen height for controls

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: shaderViewHeight,
            child: ShaderAnimationView(shaderInfo: shaderInfo),
          ),
          const Divider(height: 1),
          // Provide a fixed height for the control panel to satisfy Expanded constraints
          SizedBox(
            height: controlPanelHeight,
            child: ShaderControlPanel(shaderInfo: shaderInfo),
          ),
        ],
      ),
    );
  }
}
