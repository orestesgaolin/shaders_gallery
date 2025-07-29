import 'dart:async';
import 'dart:io';
// import 'dart:ui';

import 'package:integration_test/integration_test_driver_extended.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:image/image.dart' as img;

Future<void> main() async {
  final FlutterDriver driver = await FlutterDriver.connect();

  await integrationDriver(
    driver: driver,
    onScreenshot: (String screenshotName, List<int> screenshotBytes, [Map<String, Object?>? args]) async {
      final File file = File('assets/screenshots/$screenshotName.png');

      file.writeAsBytesSync(screenshotBytes);
      final cmd = img.Command()..decodeImageFile(file.path);
      final res = await cmd.execute();

      final image = await res.getImage();
      if (image != null) {
        final height = (image.width * 9 / 16).round();

        final croppedImage = img.copyCrop(
          image,
          x: 0,
          y: 0,
          width: image.width,
          height: height,
        );

        final croppedFile = File(file.path.replaceAll('.png', '.png'));
        await croppedFile.writeAsBytes(img.encodePng(croppedImage));
      }

      // Return false if the screenshot is invalid.
      return true;
    },
    writeResponseOnFailure: true,
  );
}
