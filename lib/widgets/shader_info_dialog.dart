import 'package:flutter/material.dart';
import '../main.dart';

/// A dialog that displays detailed information about a shader.
/// 
/// Shows shader metadata including description, author, date added,
/// asset path, and technical details like animation type and image requirements.
class ShaderInfoDialog extends StatelessWidget {
  final ShaderInfo shaderInfo;

  const ShaderInfoDialog({
    super.key,
    required this.shaderInfo,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(shaderInfo.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            label: 'Description',
            value: shaderInfo.description,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Author',
            value: shaderInfo.author,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Date Added',
            value: shaderInfo.dateAdded.toString().split(' ')[0],
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Asset',
            value: shaderInfo.assetKey,
          ),
          const SizedBox(height: 16),
          _ShaderDetails(shaderInfo: shaderInfo),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  static void show(BuildContext context, ShaderInfo shaderInfo) {
    showDialog(
      context: context,
      builder: (context) => ShaderInfoDialog(shaderInfo: shaderInfo),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _ShaderDetails extends StatelessWidget {
  final ShaderInfo shaderInfo;

  const _ShaderDetails({required this.shaderInfo});

  @override
  Widget build(BuildContext context) {
    final builder = shaderInfo.builder;
    final duration = builder.animationDuration;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Technical Details',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  builder.requiresImageSampler ? Icons.image : Icons.brush,
                  size: 16,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 8),
                Text(
                  builder.requiresImageSampler 
                      ? 'Requires image input' 
                      : 'Procedural generation',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  duration != null ? Icons.repeat : Icons.all_inclusive,
                  size: 16,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 8),
                Text(
                  duration != null 
                      ? 'Bounded animation (${duration.inMilliseconds}ms)' 
                      : 'Continuous animation',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
