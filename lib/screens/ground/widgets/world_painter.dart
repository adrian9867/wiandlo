import 'dart:math';
import 'package:flutter/material.dart';
import 'growth_stage.dart';

class WorldPainter extends CustomPainter {
  final GrowthStage stage;
  final double animValue; // 0.0–1.0, drives breathing/particles
  final List<Offset> fireflies;

  const WorldPainter({
    required this.stage,
    required this.animValue,
    required this.fireflies,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawSoil(canvas, size);
    _drawRoots(canvas, size);
    _drawPlant(canvas, size);
    if (stage.index >= GrowthStage.growing.index) {
      _drawFireflies(canvas, size);
    }
  }

  void _drawSky(Canvas canvas, Size size) {
    final stagePct = stage.index / 6.0;
    final topColor = Color.lerp(
      const Color(0xFF030608),
      const Color(0xFF0D1A0F),
      stagePct,
    )!;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [topColor, const Color(0xFF060D06)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.55));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.55),
      paint,
    );
  }

  void _drawSoil(Canvas canvas, Size size) {
    final soilY = size.height * 0.55;
    final soilColor = Color.lerp(
      const Color(0xFF1A0F0A),
      const Color(0xFF2D1A0E),
      stage.index / 6.0,
    )!;
    canvas.drawRect(
      Rect.fromLTWH(0, soilY, size.width, size.height - soilY),
      Paint()..color = soilColor,
    );
    final linePaint = Paint()
      ..color = Colors.brown.withValues(alpha: 0.07)
      ..strokeWidth = 0.5;
    for (int i = 0; i < 4; i++) {
      final y = soilY + 10 + i * 14.0;
      canvas.drawLine(
        Offset(size.width * 0.08, y),
        Offset(size.width * 0.92, y),
        linePaint,
      );
    }
  }

  void _drawRoots(Canvas canvas, Size size) {
    if (stage.index < GrowthStage.seedling.index) return;
    final cx = size.width / 2;
    final soilY = size.height * 0.55;
    final opacity = 0.12 + stage.index * 0.04;

    final paint = Paint()
      ..color = const Color(0xFFA5D6A7).withValues(alpha: opacity)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Main tap root
    _drawCurve(canvas, cx, soilY + 10, cx + 6, soilY + 40, cx + 12, soilY + 75, paint);

    if (stage.index >= GrowthStage.growing.index) {
      _drawCurve(canvas, cx, soilY + 30, cx - 28, soilY + 52, cx - 52, soilY + 85, paint);
      _drawCurve(canvas, cx, soilY + 30, cx + 28, soilY + 55, cx + 56, soilY + 88, paint);
    }

    if (stage.index >= GrowthStage.youngTree.index) {
      final deepPaint = Paint()
        ..color = const Color(0xFFA5D6A7).withValues(alpha: opacity + 0.08)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      _drawCurve(canvas, cx - 52, soilY + 85, cx - 82, soilY + 108, cx - 108, soilY + 138, deepPaint);
      _drawCurve(canvas, cx + 56, soilY + 88, cx + 84, soilY + 110, cx + 110, soilY + 140, deepPaint);
      // Hairline rootlets
      _drawCurve(canvas, cx + 12, soilY + 75, cx + 22, soilY + 95, cx + 10, soilY + 115, deepPaint);
    }
  }

  void _drawCurve(Canvas canvas, double x1, double y1, double cx, double cy,
      double x2, double y2, Paint paint) {
    final path = Path()
      ..moveTo(x1, y1)
      ..quadraticBezierTo(cx, cy, x2, y2);
    canvas.drawPath(path, paint);
  }

  void _drawPlant(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final soilY = size.height * 0.55;
    final breath = 1.0 + animValue * 0.07;

    switch (stage) {
      case GrowthStage.dormant:
        _drawSeed(canvas, cx, soilY - 7, breath);
      case GrowthStage.cracking:
        _drawSeed(canvas, cx, soilY - 7, breath * 0.85);
        _drawSprout(canvas, cx, soilY, 22, breath);
      case GrowthStage.seedling:
        _drawSprout(canvas, cx, soilY, 40, breath);
        _drawLeaf(canvas, cx, soilY - 34, left: true);
        _drawLeaf(canvas, cx, soilY - 28, left: false);
      case GrowthStage.growing:
        _drawStem(canvas, cx, soilY, 68, breath);
        for (int i = 0; i < 3; i++) {
          _drawLeaf(canvas, cx, soilY - 18 - i * 18.0, left: i.isEven);
        }
      case GrowthStage.youngTree:
        _drawStem(canvas, cx, soilY, 95, breath);
        for (int i = 0; i < 5; i++) {
          _drawLeaf(canvas, cx, soilY - 22 - i * 16.0, left: i.isEven, scale: 1.2);
        }
      case GrowthStage.blooming:
        _drawStem(canvas, cx, soilY, 115, breath);
        for (int i = 0; i < 6; i++) {
          _drawLeaf(canvas, cx, soilY - 24 - i * 15.0, left: i.isEven, scale: 1.3);
        }
        _drawBlossoms(canvas, cx, soilY - 115, animValue);
      case GrowthStage.forest:
        final positions = [size.width * 0.22, cx, size.width * 0.78];
        final heights = [88.0, 115.0, 92.0];
        for (int i = 0; i < 3; i++) {
          _drawStem(canvas, positions[i], soilY, heights[i], breath);
          for (int j = 0; j < 5; j++) {
            _drawLeaf(canvas, positions[i], soilY - 20 - j * 16.0,
                left: j.isEven, scale: 1.1);
          }
        }
    }
  }

  void _drawSeed(Canvas canvas, double x, double y, double scale) {
    final glow = Paint()
      ..color = const Color(0xFFA5D6A7).withValues(alpha: 0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(Offset(x, y), 14 * scale, glow);

    final seed = Paint()..color = const Color(0xFFA5D6A7).withValues(alpha: 0.55);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(x, y), width: 11 * scale, height: 15 * scale),
      seed,
    );
  }

  void _drawSprout(Canvas canvas, double x, double soilY, double h, double scale) {
    _drawSeed(canvas, x, soilY - 5, scale * 0.75);
    final paint = Paint()
      ..color = const Color(0xFF81C784).withValues(alpha: 0.65)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, soilY - 9), Offset(x + 3, soilY - h), paint);
  }

  void _drawStem(Canvas canvas, double x, double soilY, double h, double scale) {
    final paint = Paint()
      ..color = const Color(0xFF558B2F).withValues(alpha: 0.75)
      ..strokeWidth = 2.8 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, soilY - 4), Offset(x, soilY - h), paint);
  }

  void _drawLeaf(Canvas canvas, double x, double y,
      {required bool left, double scale = 1.0}) {
    final paint = Paint()
      ..color = const Color(0xFF81C784).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final path = Path();
    final dir = left ? -1 : 1;
    path.moveTo(x, y);
    path.quadraticBezierTo(
        x + dir * 16 * scale, y - 8 * scale, x + dir * 13 * scale, y - 20 * scale);
    path.quadraticBezierTo(x + dir * 2 * scale, y - 11 * scale, x, y);
    canvas.drawPath(path, paint);
  }

  void _drawBlossoms(Canvas canvas, double cx, double cy, double anim) {
    final paint = Paint()
      ..color = const Color(0xFFF8BBD9).withValues(alpha: 0.45 + anim * 0.25)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      final angle = i * pi * 2 / 5;
      canvas.drawCircle(
        Offset(cx + cos(angle) * 16, cy + sin(angle) * 10),
        5 + anim * 2.5,
        paint,
      );
    }
    // Center bloom
    canvas.drawCircle(
      Offset(cx, cy),
      4 + anim * 1.5,
      Paint()..color = const Color(0xFFFFF9C4).withValues(alpha: 0.6 + anim * 0.2),
    );
  }

  void _drawFireflies(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFE082).withValues(alpha: 0.3 + animValue * 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    for (final pos in fireflies) {
      canvas.drawCircle(
        Offset(pos.dx * size.width, pos.dy * size.height * 0.52),
        2.2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WorldPainter old) =>
      old.animValue != animValue || old.stage != stage;
}