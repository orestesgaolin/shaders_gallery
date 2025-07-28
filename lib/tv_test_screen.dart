import 'package:flutter/material.dart';
import 'dart:math' as math;

class TvTestScreen extends StatelessWidget {
  const TvTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3, // Classic TV aspect ratio
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: const CustomPaint(
          painter: TvTestScreenPainter(),
        ),
      ),
    );
  }
}

class TvTestScreenPainter extends CustomPainter {
  const TvTestScreenPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = Colors.grey.shade400,
    );

    // Top section with color bars
    _drawColorBars(canvas, width, height);

    // Middle section with test patterns
    _drawMiddleSection(canvas, width, height);

    // Bottom section with frequency bars
    _drawBottomSection(canvas, width, height);

    // Corner circles
    _drawCornerCircles(canvas, width, height);

    // Grid overlay
    _drawGrid(canvas, width, height);
  }

  void _drawColorBars(Canvas canvas, double width, double height) {
    const colors = [
      Colors.white,
      Color(0xFFFFFF00), // Yellow
      Color(0xFF00FFFF), // Cyan
      Color(0xFF00FF00), // Green
      Color(0xFFFF00FF), // Magenta
      Color(0xFFFF0000), // Red
      Color(0xFF0000FF), // Blue
      Colors.black,
    ];

    final barWidth = width / colors.length;
    final barHeight = height * 0.6;

    for (int i = 0; i < colors.length; i++) {
      canvas.drawRect(
        Rect.fromLTWH(i * barWidth, 0, barWidth, barHeight),
        Paint()..color = colors[i],
      );
    }
  }

  void _drawMiddleSection(Canvas canvas, double width, double height) {
    final startY = height * 0.6;
    final sectionHeight = height * 0.2;

    // Left side - gradient ramp
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.black, Colors.white],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, startY, width * 0.3, sectionHeight));

    canvas.drawRect(
      Rect.fromLTWH(0, startY, width * 0.3, sectionHeight),
      gradientPaint,
    );

    // Center - crosshatch pattern
    _drawCrosshatch(canvas, width * 0.3, startY, width * 0.4, sectionHeight);

    // Right side - vertical lines
    _drawVerticalLines(canvas, width * 0.7, startY, width * 0.3, sectionHeight);
  }

  void _drawCrosshatch(Canvas canvas, double x, double y, double w, double h) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    final spacing = 8.0;
    
    // Horizontal lines
    for (double i = y; i <= y + h; i += spacing) {
      canvas.drawLine(Offset(x, i), Offset(x + w, i), paint);
    }
    
    // Vertical lines
    for (double i = x; i <= x + w; i += spacing) {
      canvas.drawLine(Offset(i, y), Offset(i, y + h), paint);
    }
  }

  void _drawVerticalLines(Canvas canvas, double x, double y, double w, double h) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    final spacing = 2.0;
    for (double i = x; i <= x + w; i += spacing) {
      canvas.drawLine(Offset(i, y), Offset(i, y + h), paint);
    }
  }

  void _drawBottomSection(Canvas canvas, double width, double height) {
    final startY = height * 0.8;
    final sectionHeight = height * 0.2;

    // Frequency test bars
    const frequencies = [1, 2, 4, 8, 16, 32];
    final barWidth = width / frequencies.length;

    for (int i = 0; i < frequencies.length; i++) {
      final freq = frequencies[i];
      final paint = Paint()..color = Colors.black;
      
      final x = i * barWidth;
      final lineSpacing = barWidth / (freq * 2);
      
      for (double j = 0; j < barWidth; j += lineSpacing * 2) {
        canvas.drawRect(
          Rect.fromLTWH(x + j, startY, lineSpacing, sectionHeight),
          paint,
        );
      }
    }
  }

  void _drawCornerCircles(Canvas canvas, double width, double height) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final radius = math.min(width, height) * 0.08;
    final positions = [
      Offset(radius + 10, radius + 10), // Top-left
      Offset(width - radius - 10, radius + 10), // Top-right
      Offset(radius + 10, height - radius - 10), // Bottom-left
      Offset(width - radius - 10, height - radius - 10), // Bottom-right
    ];

    for (final pos in positions) {
      // Outer circle
      canvas.drawCircle(pos, radius, paint);
      
      // Inner crosshair
      canvas.drawLine(
        Offset(pos.dx - radius * 0.7, pos.dy),
        Offset(pos.dx + radius * 0.7, pos.dy),
        paint,
      );
      canvas.drawLine(
        Offset(pos.dx, pos.dy - radius * 0.7),
        Offset(pos.dx, pos.dy + radius * 0.7),
        paint,
      );
      
      // Center dot
      canvas.drawCircle(pos, 3, Paint()..color = Colors.black);
    }
  }

  void _drawGrid(Canvas canvas, double width, double height) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 0.5;

    const gridSpacing = 20.0;
    
    // Vertical lines
    for (double x = 0; x <= width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, height), paint);
    }
    
    // Horizontal lines
    for (double y = 0; y <= height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
