import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TopMenu extends StatelessWidget {
  const TopMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid
        final isCompact = constraints.maxWidth < 600;

        if (isCompact) {
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
            child: Row(
              children: [
                // Home button
                ShadButton(
                  onPressed: () => context.go('/'),
                  child: Icon(Icons.home, size: 20),
                ),
                const Spacer(),
                if (isRunningWithWasm) ...[
                  const SizedBox(width: 8),
                  Text('${FlutterVersion.version} (WASM)'),
                ],
              ],
            ),
          );
        }

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
              // Home button
              ShadButton(
                onPressed: () => context.go('/'),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home, size: 20),
                    SizedBox(width: 8),
                    Text('Shader Gallery'),
                  ],
                ),
              ),
              const Spacer(),
              FlutterLogo(size: 14),
              Text(FlutterVersion.version ?? ''),
              if (isRunningWithWasm) ...[
                Text(' WASM'),
              ],
            ],
          ),
        );
      },
    );
  }
}

const isRunningWithWasm = bool.fromEnvironment('dart.tool.dart2wasm');
