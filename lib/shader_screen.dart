import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:shaders/widgets/details_top_menu.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/widgets.dart';
import 'main.dart';
import 'shader_source_viewer.dart';

/// The main screen for displaying a specific shader with side-by-side layout.
///
/// Shows the shader animation on the left and the source code on the right
/// for desktop, or stacks them vertically for mobile.
class ShaderScreen extends StatelessWidget {
  const ShaderScreen({super.key, required this.shaderInfo});

  final ShaderInfo shaderInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top menu (same as home screen)
            _buildTopMenu(context),
            // Main content
            Expanded(child: _buildMainContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopMenu(BuildContext context) {
    return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ShadTheme.of(context).colorScheme.border,
            width: 1,
          ),
        ),
      ),
      child: DetailsTopMenu(shaderInfo: shaderInfo),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 800;

        if (isWideScreen) {
          return Row(
            children: [
              // Shader view
              Expanded(child: ShaderAnimationView(shaderInfo: shaderInfo)),
              // Vertical divider
              Container(
                width: 1,
                color: ShadTheme.of(context).colorScheme.border,
              ),
              // Source code view
              Expanded(child: RightColumn(shaderInfo: shaderInfo)),
            ],
          );
        } else {
          return ListView(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * 0.6,
                ),
                child: ShaderAnimationView(shaderInfo: shaderInfo),
              ),
              // Horizontal divider
              Container(
                height: 1,
                color: ShadTheme.of(context).colorScheme.border,
              ),
              // Source code view (bottom half)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 1200,
                ),
                child: RightColumn(shaderInfo: shaderInfo),
              ),
            ],
          );
        }
      },
    );
  }
}

class RightColumn extends StatelessWidget {
  const RightColumn({super.key, required this.shaderInfo});

  final ShaderInfo shaderInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details', style: ShadTheme.of(context).textTheme.h4),
          InfoView(shaderInfo: shaderInfo),
          const SizedBox(height: 8),
          Text('Shader Source Code', style: ShadTheme.of(context).textTheme.h4),
          const SizedBox(height: 8),
          Expanded(
            child: ShaderSourceViewer(
              assetKey: shaderInfo.assetKey,
              shaderName: shaderInfo.name,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoView extends StatelessWidget {
  const InfoView({super.key, required this.shaderInfo});

  final ShaderInfo shaderInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description: ${shaderInfo.description}'),
        const SizedBox(height: 8),
        Text('Author: ${shaderInfo.author}'),
        const SizedBox(height: 8),
        Text('Date Added: ${shaderInfo.dateAdded.toString().split(' ')[0]}'),
      ],
    );
  }
}
