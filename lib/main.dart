import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'crt_shader_config.dart';
import 'noise_overlay_shader_config.dart';
import 'noise_shader_config.dart';
import 'ntsc_shader_config.dart';
import 'shader_configs.dart';
import 'shader_screen.dart';
import 'tv_test_screen.dart';

void main() {
  runApp(const RgbGlitchDemo());
}

class ShaderInfo {
  final String name;
  final String assetKey;
  final String description;
  final String sourceUrl;
  final ShaderConfig config;

  const ShaderInfo({
    required this.name,
    required this.assetKey,
    required this.description,
    required this.sourceUrl,
    required this.config,
  });
}

final shaders = [
  const ShaderInfo(
    name: 'NTSC',
    assetKey: 'shaders/ntsc_shader.frag',
    description: 'An effect that emulates an old NTSC television signal.',
    sourceUrl: 'https://www.shadertoy.com/view/3tVBWR',
    config: NtscShaderConfig(),
  ),
  const ShaderInfo(
    name: 'CRT',
    assetKey: 'shaders/crt_shader.frag',
    description: 'A glitching screen effect',
    sourceUrl: 'https://www.shadertoy.com/view/lt3yz7',
    config: CrtShaderConfig(),
  ),
  const ShaderInfo(
    name: 'Noise',
    assetKey: 'shaders/noise_shader.frag',
    description: 'Animated gradient noise with film grain effect',
    sourceUrl: 'https://www.shadertoy.com/view/DdcfzH',
    config: NoiseShaderConfig(),
  ),
  const ShaderInfo(
    name: 'Noise Overlay',
    assetKey: 'shaders/noise_overlay_shader.frag',
    description: 'Applies animated noise effect as an overlay on content',
    sourceUrl: 'https://www.shadertoy.com/view/DdcfzH',
    config: NoiseOverlayShaderConfig(),
  ),
];

class RgbGlitchDemo extends StatefulWidget {
  const RgbGlitchDemo({super.key});

  @override
  State<RgbGlitchDemo> createState() => _RgbGlitchDemoState();
}

class _RgbGlitchDemoState extends State<RgbGlitchDemo> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shader Gallery'), centerTitle: true),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 350,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 4 / 3,
            ),
            itemCount: shaders.length,
            itemBuilder: (context, index) {
              final shaderInfo = shaders[index];
              return _ShaderTile(
                shaderInfo: shaderInfo,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ShaderScreen(shaderInfo: shaderInfo),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ShaderTile extends StatelessWidget {
  const _ShaderTile({required this.shaderInfo, required this.onTap});

  final ShaderInfo shaderInfo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black45,
            title: Text(shaderInfo.name, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              shaderInfo.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.link),
              tooltip: 'View Source',
              onPressed: () async {
                final url = Uri.parse(shaderInfo.sourceUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: TvTestScreen(),
          ),
        ),
      ),
    );
  }
}
