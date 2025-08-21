import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shaders/main.dart';

class ShaderCard extends StatelessWidget {
  const ShaderCard({super.key, required this.shaderInfo, required this.onTap});

  final ShaderInfo shaderInfo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),

      child: ShadCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                'assets/screenshots/${shaderInfo.path}.png',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shaderInfo.name,
                    style: ShadTheme.of(context).textTheme.h2,
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: shaderInfo.description),
                        TextSpan(text: 'by ${shaderInfo.author}'),
                      ],
                      style: ShadTheme.of(context).textTheme.muted,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
