import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shaders/widgets/widgets.dart';

import 'shader_builder.dart';
import 'crt_shader_builder.dart';
import 'noise_overlay_shader_builder.dart';
import 'noise_shader_builder.dart';
import 'ntsc_shader_builder.dart';
import 'rings_shader_builder.dart';
import 'shader_screen.dart';

void main() {
  usePathUrlStrategy();

  runApp(const RgbGlitchDemo());
}

class ShaderInfo {
  final String name;
  final String assetKey;
  final String description;
  final String sourceUrl;
  final String author;
  final DateTime dateAdded;
  final CustomShaderBuilder builder;
  final String path;

  const ShaderInfo({
    required this.name,
    required this.assetKey,
    required this.description,
    required this.sourceUrl,
    required this.author,
    required this.dateAdded,
    required this.builder,
    required this.path,
  });

  ShaderMetadata get metadata => ShaderMetadata(
    assetKey: assetKey,
    name: name,
    url: sourceUrl,
    author: author,
    dateAdded: dateAdded,
  );
}

final shaders = [
  ShaderInfo(
    name: 'NTSC filter',
    assetKey: 'shaders/ntsc_shader.frag',
    description: 'An effect that emulates an old NTSC television signal.',
    sourceUrl: 'https://www.shadertoy.com/view/3tVBWR',
    author: 'BitOfGold',
    dateAdded: DateTime(2025, 7, 28),
    builder: const NtscShaderBuilder(),
    path: 'ntsc-shader',
  ),
  ShaderInfo(
    name: 'Interlaced Glitch CRT',
    assetKey: 'shaders/crt_shader.frag',
    description: 'A glitching screen effect',
    sourceUrl: 'https://www.shadertoy.com/view/lt3yz7',
    author: '@tommclaughlan',
    dateAdded: DateTime(2025, 7, 28),
    builder: const CrtShaderBuilder(),
    path: 'crt-shader',
  ),
  ShaderInfo(
    name: 'Lava Lamp Gradient',
    assetKey: 'shaders/noise_shader.frag',
    description: 'Animated gradient noise with film grain effect',
    sourceUrl: 'https://www.shadertoy.com/view/DdcfzH',
    author: 'welches',
    dateAdded: DateTime(2025, 7, 28),
    builder: const NoiseShaderBuilder(),
    path: 'noise-shader',
  ),
  ShaderInfo(
    name: 'Noise Overlay',
    assetKey: 'shaders/noise_overlay_shader.frag',
    description: 'Applies animated noise effect as an overlay on content',
    sourceUrl: 'https://www.shadertoy.com/view/DdcfzH',
    path: 'noise-overlay-shader',
    author: 'welches',
    dateAdded: DateTime(2025, 7, 28),
    builder: const NoiseOverlayShaderBuilder(),
  ),
  ShaderInfo(
    name: 'Interactive Rings',
    assetKey: 'shaders/rings_shader.frag',
    description: 'Animated rings that respond to touch and mouse interaction. Tap and move around quickly.',
    sourceUrl: 'https://www.shadertoy.com/view/Xtj3DW',
    author: 'Pol Jeremias',
    dateAdded: DateTime(2025, 7, 29),
    builder: const RingsShaderBuilder(),
    path: 'rings-shader',
  ),
];

// Helper function to create URL-safe shader names
String shaderNameToPath(String name) {
  return name.toLowerCase().replaceAll(' ', '-');
}

// Helper function to find shader by path
ShaderInfo? findShaderByPath(String path) {
  try {
    return shaders.firstWhere((shader) => shader.path == path);
  } catch (e) {
    return null;
  }
}

// Router configuration
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/shader/:shaderName',
      name: 'shader',
      builder: (context, state) {
        final shaderName = state.pathParameters['shaderName']!;
        final shaderInfo = findShaderByPath(shaderName);

        if (shaderInfo == null) {
          // If shader not found, redirect to home
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/');
          });
          return const HomeScreen();
        }

        return ShaderScreen(shaderInfo: shaderInfo);
      },
    ),
  ],
  errorBuilder: (context, state) => const HomeScreen(),
);

// Custom page transition builder that provides no animation (instant transition)
class _NoTransitionPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionPageTransitionsBuilder();

  @override
  Widget buildTransitions<T extends Object?>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class RgbGlitchDemo extends StatefulWidget {
  const RgbGlitchDemo({super.key});

  @override
  State<RgbGlitchDemo> createState() => _RgbGlitchDemoState();
}

class _RgbGlitchDemoState extends State<RgbGlitchDemo> {
  @override
  Widget build(BuildContext context) {
    return ShadApp.custom(
      themeMode: ThemeMode.light,

      appBuilder: (context) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          theme: Theme.of(context).copyWith(
            pageTransitionsTheme: kIsWeb || defaultTargetPlatform.isDesktop
                ? PageTransitionsTheme(
                    builders: {
                      TargetPlatform.android: const _NoTransitionPageTransitionsBuilder(),
                      TargetPlatform.iOS: const _NoTransitionPageTransitionsBuilder(),
                      TargetPlatform.linux: const _NoTransitionPageTransitionsBuilder(),
                      TargetPlatform.macOS: const _NoTransitionPageTransitionsBuilder(),
                      TargetPlatform.windows: const _NoTransitionPageTransitionsBuilder(),
                    },
                  )
                : null,
          ),
          builder: (context, child) {
            return ShadAppBuilder(child: child!);
          },
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const TopMenu(),
            Expanded(child: ContentGrid()),
          ],
        ),
      ),
    );
  }
}

class ContentGrid extends StatelessWidget {
  const ContentGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid
        int crossAxisCount;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 4 / 3,
          ),
          itemCount: shaders.length,
          itemBuilder: (context, index) {
            final shaderInfo = shaders[index];
            return _ShaderCard(
              shaderInfo: shaderInfo,
              onTap: () {
                context.go('/shader/${shaderInfo.path}');
              },
            );
          },
        );
      },
    );
  }
}

class _ShaderCard extends StatelessWidget {
  const _ShaderCard({required this.shaderInfo, required this.onTap});

  final ShaderInfo shaderInfo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: ShadCard(
        title: Text(shaderInfo.name),
        footer: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'by ${shaderInfo.author}'),
            ],
          ),
          style: ShadTheme.of(context).textTheme.small,
        ),
        description: Text(
          shaderInfo.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

extension on TargetPlatform {
  bool get isDesktop {
    return this == TargetPlatform.macOS || this == TargetPlatform.windows || this == TargetPlatform.linux;
  }
}
