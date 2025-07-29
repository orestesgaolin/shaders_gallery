import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shaders/fullscreen_shader_widget.dart';
import 'package:shaders/main.dart';
import 'package:flutter/material.dart';

void main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Shader Screenshot Tests', () {
    for (final shaderInfo in shaders) {
      testWidgets('Screenshot for ${shaderInfo.name}', (WidgetTester tester) async {
        // Build the fullscreen shader widget
        // set tester size to 16:9

        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: AspectRatio(
                aspectRatio: 16 / 9,
                child: FullscreenShaderWidget(
                  shaderInfo: shaderInfo,
                ),
              ),
            ),
          ),
        );
        await binding.convertFlutterSurfaceToImage();

        // Wait for the shader to initialize and animate a bit
        await tester.pump(const Duration(milliseconds: 1000));
        await tester.pump(const Duration(milliseconds: 1000));

        // Take a screenshot
        await tester.binding.delayed(const Duration(milliseconds: 100));

        // Save the screenshot with a specific filename
        final screenshotData = await binding.takeScreenshot(shaderInfo.path);

        print('Screenshot taken for ${shaderInfo.name} of size: ${screenshotData.length} bytes');
      });
    }
  });
}
