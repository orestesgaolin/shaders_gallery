import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shaders/main.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsTopMenu extends StatelessWidget {
  const DetailsTopMenu({
    super.key,
    required this.shaderInfo,
  });

  final ShaderInfo shaderInfo;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        if (isCompact) {
          return Row(
            children: [
              ShadButton(
                onPressed: () => context.go('/'),
                child: Icon(Icons.arrow_back, size: 20),
              ),
              Spacer(),
              ShadButton(
                onPressed: () async {
                  final url = Uri.parse(shaderInfo.sourceUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                child: Icon(Icons.code, size: 16),
              ),
            ],
          );
        }

        return Row(
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
        );
      },
    );
  }
}
