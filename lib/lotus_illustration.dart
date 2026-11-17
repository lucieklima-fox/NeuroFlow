import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Motiv ilustrace podle typu cvičení.
enum CalmMotif { lotus, seated, breath }

CalmMotif motifForExercise(String title) {
  final t = title.toLowerCase();
  if (t.contains('dech') || t.contains('nádech') || t.contains('výdech')) {
    return CalmMotif.breath;
  }
  if (t.contains('sed') || t.contains('poloh') || t.contains('postoj')) {
    return CalmMotif.seated;
  }
  return CalmMotif.lotus;
}

/// Jemná vektorová ilustrace kreslená přímo ve Flutteru (bez obrázků).
class CalmIllustration extends StatelessWidget {
  final CalmMotif motif;
  final String label;
  final double size;

  const CalmIllustration({
    super.key,
    required this.motif,
    required this.label,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _CalmPainter(motif)),
      ),
    );
  }
}

const Color _turquoise = Color(0xFF90E0EF);
const Color _turquoiseFill = Color(0x3390E0EF);
const Color _gold = Color(0xFFE9C46A);
const Color _goldSoft = Color(0x99E9C46A);

class _CalmPainter extends CustomPainter {
  final CalmMotif motif;

  _CalmPainter(this.motif);

  @override
  void paint(Canvas canvas, Size size) {
    switch (motif) {
      case CalmMotif.lotus:
        _drawLotus(canvas, size);
        break;
      case CalmMotif.seated:
        _drawSeated(canvas, size);
        break;
      case CalmMotif.breath:
        _drawBreath(canvas, size);
        break;
    }
  }

  void _drawLotus(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height * 0.6);
    final fill = Paint()..color = _turquoiseFill;
    final edge = Paint()
      ..color = _goldSoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final angle in [-0.9, -0.45, 0.0, 0.45, 0.9]) {
      canvas.save();
      canvas.translate(centre.dx, centre.dy);
      canvas.rotate(angle);
      final rect = Rect.fromCenter(
        center: Offset(0, -size.height * 0.2),
        width: size.width * 0.18,
        height: size.height * 0.42,
      );
      canvas.drawOval(rect, fill);
      canvas.drawOval(rect, edge);
      canvas.restore();
    }
    canvas.drawCircle(centre, size.width * 0.05, Paint()..color = _gold);
  }

  void _drawSeated(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()..color = _turquoiseFill;
    final stroke = Paint()
      ..color = _turquoise
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final head = Offset(w / 2, h * 0.22);
    canvas.drawCircle(head, w * 0.09, fill);
    canvas.drawCircle(head, w * 0.09, stroke);
    final body = Path()
      ..moveTo(w * 0.5, h * 0.33)
      ..quadraticBezierTo(w * 0.36, h * 0.5, w * 0.34, h * 0.62)
      ..lineTo(w * 0.66, h * 0.62)
      ..quadraticBezierTo(w * 0.64, h * 0.5, w * 0.5, h * 0.33)
      ..close();
    canvas.drawPath(body, fill);
    canvas.drawPath(body, stroke);
    final legs = Path()
      ..moveTo(w * 0.2, h * 0.7)
      ..quadraticBezierTo(w * 0.5, h * 0.95, w * 0.8, h * 0.7);
    canvas.drawPath(
      legs,
      Paint()
        ..color = _gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawBreath(Canvas canvas, Size size) {
    for (var i = 0; i < 3; i++) {
      final baseY = size.height * (0.4 + i * 0.15);
      final path = Path()..moveTo(0, baseY);
      for (double x = 0; x <= size.width; x += 3) {
        final y = baseY +
            math.sin(x / size.width * 2 * math.pi + i * 0.8) * size.height * 0.05;
        path.lineTo(x, y);
      }
      final color = i == 1 ? _gold : _turquoise;
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CalmPainter oldDelegate) =>
      oldDelegate.motif != motif;
}
