import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:go_router/go_router.dart';
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
      body: Column(
        children: [
          // Top menu (same as home screen)
          _buildTopMenu(context),
          // Main content
          Expanded(child: _buildMainContent(context)),
        ],
      ),
    );
  }

  Widget _buildTopMenu(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ShadTheme.of(context).colorScheme.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back to home button
          ShadButton(
            onPressed: () => context.go('/'),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, size: 20),
                SizedBox(width: 8),
                Text('Back to Gallery'),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Shader title
          Expanded(
            child: Text(
              shaderInfo.name,
              style: ShadTheme.of(context).textTheme.h3,
            ),
          ),
          // Actions
          Row(
            children: [
              ShadButton.outline(
                onPressed: () async {
                  final url = Uri.parse(shaderInfo.sourceUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.link, size: 16),
                    SizedBox(width: 8),
                    Text('View Source'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
          return Column(
            children: [
              // Shader view (top half)
              Expanded(child: ShaderAnimationView(shaderInfo: shaderInfo)),
              // Horizontal divider
              Container(
                height: 1,
                color: ShadTheme.of(context).colorScheme.border,
              ),
              // Source code view (bottom half)
              Expanded(child: RightColumn(shaderInfo: shaderInfo)),
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
