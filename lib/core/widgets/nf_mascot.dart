import 'package:flutter/material.dart';

enum MascotMood { happy, calm, listening }

class NFMascot extends StatelessWidget {
  final double size;
  final MascotMood mood;

  const NFMascot({super.key, this.size = 120, this.mood = MascotMood.happy});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.95),
      painter: _MascotPainter(mood: mood),
    );
  }
}

class _MascotPainter extends CustomPainter {
  final MascotMood mood;
  _MascotPainter({required this.mood});

  @override
  void paint(Canvas canvas, Size size) {
    // viewBox is 120x114
    final sx = size.width / 120.0;
    final sy = size.height / 114.0;
    Offset p(double x, double y) => Offset(x * sx, y * sy);

    final ear = Paint()..color = const Color(0xFF2E5290);
    // left ear: rect 2,46 w22 h34 rx11
    _rrect(canvas, p(2, 46), 22 * sx, 34 * sy, 11 * sx, ear);
    _rrect(canvas, p(96, 46), 22 * sx, 34 * sy, 11 * sx, ear);

    // head circle r44 at (60,58)
    canvas.drawCircle(p(60, 58), 44 * sx, Paint()..color = const Color(0xFF4C8CE4));

    // highlight ellipse
    canvas.drawOval(
      Rect.fromCenter(center: p(44, 42), width: 28 * sx, height: 18 * sy),
      Paint()..color = Colors.white.withOpacity(0.18),
    );

    // antenna line + dot
    final antennaPaint = Paint()
      ..color = const Color(0xFF2E5290)
      ..strokeWidth = 3 * sx
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p(60, 14), p(60, 6), antennaPaint);
    canvas.drawCircle(p(60, 5), 3.5 * sx, Paint()..color = const Color(0xFF2E5290));

    // eyes
    final eye = Paint()..color = const Color(0xFF1B2440);
    canvas.drawCircle(p(46, 58), 6 * sx, eye);
    canvas.drawCircle(p(74, 58), 6 * sx, eye);
    final highlight = Paint()..color = Colors.white;
    canvas.drawCircle(p(48, 56), 1.6 * sx, highlight);
    canvas.drawCircle(p(76, 56), 1.6 * sx, highlight);

    // mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF1B2440)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * sx
      ..strokeCap = StrokeCap.round;
    if (mood == MascotMood.happy) {
      final path = Path()
        ..moveTo(p(50, 74).dx, p(50, 74).dy)
        ..quadraticBezierTo(p(60, 84).dx, p(60, 84).dy, p(70, 74).dx, p(70, 74).dy);
      canvas.drawPath(path, mouthPaint);
    } else if (mood == MascotMood.calm) {
      final path = Path()
        ..moveTo(p(52, 76).dx, p(52, 76).dy)
        ..quadraticBezierTo(p(60, 80).dx, p(60, 80).dy, p(68, 76).dx, p(68, 76).dy);
      canvas.drawPath(path, mouthPaint);
    } else {
      canvas.drawOval(
        Rect.fromCenter(center: p(60, 76), width: 8 * sx, height: 10 * sy),
        Paint()..color = const Color(0xFF1B2440),
      );
    }

    // feet
    final foot = Paint()..color = const Color(0xFF2E5290);
    canvas.drawOval(
      Rect.fromCenter(center: p(44, 106), width: 18 * sx, height: 10 * sy),
      foot,
    );
    canvas.drawOval(
      Rect.fromCenter(center: p(76, 106), width: 18 * sx, height: 10 * sy),
      foot,
    );
  }

  void _rrect(Canvas c, Offset topLeft, double w, double h, double r, Paint p) {
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(topLeft.dx, topLeft.dy, w, h),
        Radius.circular(r),
      ),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _MascotPainter old) => old.mood != mood;
}
