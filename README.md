# Shaders Gallery

A Flutter web application showcasing various shader effects including NTSC, CRT, Noise, and Noise Overlay shaders.

![](docs/screenshot.png)



## Maintenance

### Regenerating screenshots

```sh
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/shader_screenshots_test.dart -d sm
```