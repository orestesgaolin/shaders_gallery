import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shaders/widgets/shader_card.dart';
import 'package:shaders/widgets/widgets.dart';
import 'package:shaders/meta/meta_tag_manager.dart';

import 'common_shader_builder.dart';
import 'distorted_motion_shader_builder.dart';
import 'shader_builder.dart';
import 'crt_shader_builder.dart';
import 'noise_overlay_shader_builder.dart';
import 'noise_shader_builder.dart';
import 'ntsc_shader_builder.dart';
import 'rings_shader_builder.dart';
import 'shader_screen.dart';
import 'branded_ai_assistant_shader_builder.dart';

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
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? aspectRatio;

  const ShaderInfo({
    required this.name,
    required this.assetKey,
    required this.description,
    required this.sourceUrl,
    required this.author,
    required this.dateAdded,
    required this.builder,
    required this.path,
    this.padding,
    this.backgroundColor,
    this.aspectRatio,
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
    aspectRatio: 1,
  ),
  ShaderInfo(
    name: 'Clearly a Bug',
    assetKey: 'shaders/clearly_bug_shader.frag',
    description: 'A "Happy Accident" raymarching shader with fractal patterns and beautiful lighting.',
    sourceUrl: 'https://www.shadertoy.com/view/33cGDj',
    author: 'mrange',
    dateAdded: DateTime(2025, 7, 29),
    builder: const CommonShaderBuilder(),
    path: 'clearly-bug-shader',
    backgroundColor: Colors.black,
  ),
  ShaderInfo(
    name: 'AI Assistant',
    assetKey: 'shaders/ai_assistant.frag',
    description: 'A rotating effect resembling an AI assistant.',
    sourceUrl: 'https://www.shadertoy.com/view/MXsyzl',
    author: 'Saphirah',
    dateAdded: DateTime(2025, 8, 21),
    builder: const CommonShaderBuilder(),
    path: 'ai-assistant',
    padding: EdgeInsets.all(32),
    backgroundColor: Colors.black,
    aspectRatio: 1,
  ),
  ShaderInfo(
    assetKey: 'shaders/branded_ai_assistant.frag',
    name: 'Branded AI Assistant',
    description: 'Simple scifi ai assistant orb. Use mouse hover to interact.',
    sourceUrl: 'https://www.shadertoy.com/view/tfcGD8',
    author: 'Wickone',
    dateAdded: DateTime(2025, 8, 21),
    builder: const BrandedAiAssistantShaderBuilder(),
    path: 'branded-ai-assistant',
    backgroundColor: Colors.black,
    aspectRatio: 1,
  ),
  ShaderInfo(
    assetKey: 'shaders/breathing_point.frag',
    name: 'Breathing Point',
    description: 'A calming shader that simulates breathing.',
    sourceUrl: 'https://www.shadertoy.com/view/4dXyWN',
    author: 'User5518',
    dateAdded: DateTime(2025, 8, 21),
    builder: const CommonShaderBuilder(),
    path: 'breathing-point',
    backgroundColor: Colors.black,
    aspectRatio: 1,
  ),
  // glitch.frag
  ShaderInfo(
    assetKey: 'shaders/distorted_motion.frag',
    name: 'Distorted Motion',
    description: 'Distorts the UI with a blur while scrolling',
    sourceUrl: 'https://fluttershaders.com/shaders/distorted-motion-blur/',
    author: '@raoufrahiche',
    dateAdded: DateTime(2025, 8, 21),
    builder: const DistortedMotionShaderBuilder(),
    path: 'distorted-motion',
  ),
  ShaderInfo(
    assetKey: 'shaders/plasma_xor.frag',
    name: 'Plasma',
    description: 'A ball of plasma?',
    sourceUrl: 'https://www.shadertoy.com/view/WfS3Dd',
    author: 'xor',
    dateAdded: DateTime(2025, 8, 22),
    builder: const CommonShaderBuilder(),
    path: 'plasma-xor',
    backgroundColor: Colors.black,
    aspectRatio: 1,
  ),
  ShaderInfo(
    assetKey: 'shaders/sea.frag',
    name: 'Seascape',
    description: 'fully-procedural sea surface computing. without textures. Try clicking and moving around with your mouse. Adapted to Flutter by @reNotANumber',
    sourceUrl: 'https://www.shadertoy.com/view/Ms2SD1',
    author: 'TDM, reNotANumber',
    dateAdded: DateTime(2025, 9, 2),
    builder: const CommonShaderBuilder(enableMouse: true),
    path: 'sea',
    backgroundColor: Colors.white,
    aspectRatio: 1,
  ),
];

List<ShaderInfo> sortedShaders = List.from(shaders)..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

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
      builder: (context, state) {
        // Update meta tags for home page
        if (kIsWeb) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            MetaTagManager.updateForHomePage();
          });
        }
        return const HomeScreen();
      },
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

        // Update meta tags for this shader
        if (kIsWeb) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            MetaTagManager.updateForShader(
              shaderName: shaderInfo.path,
              shaderTitle: shaderInfo.name,
              description: shaderInfo.description,
              author: shaderInfo.author,
              imageUrl: MetaTagManager.getShaderImageUrl(shaderInfo.path),
              sourceUrl: shaderInfo.sourceUrl,
            );
          });
        }

        return ShaderScreen(shaderInfo: shaderInfo);
      },
    ),
  ],
  errorBuilder: (context, state) {
    // Update meta tags for error/home page
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        MetaTagManager.updateForHomePage();
      });
    }
    return const HomeScreen();
  },
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
      theme: ShadThemeData(
        colorScheme: ShadGrayColorScheme.light(),
        brightness: Brightness.light,
        textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.poppins),
      ),

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
            childAspectRatio: 1,
          ),
          itemCount: sortedShaders.length,
          itemBuilder: (context, index) {
            final shaderInfo = sortedShaders[index];
            return ShaderCard(
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

extension on TargetPlatform {
  bool get isDesktop {
    return this == TargetPlatform.macOS || this == TargetPlatform.windows || this == TargetPlatform.linux;
  }
}
