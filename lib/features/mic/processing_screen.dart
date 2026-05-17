import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/nf_mascot.dart';
import '../../core/widgets/nf_screen.dart';

class ProcessingScreen extends StatefulWidget {
  /// Destination route name passed via Navigator arguments.
  final String? nextRoute;
  const ProcessingScreen({super.key, this.nextRoute});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _spin;
  Timer? _timer;
  late final AnimationController _dots;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
    _dots = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
    _timer = Timer(const Duration(milliseconds: 1900), () {
      if (!mounted) return;
      final route = widget.nextRoute ??
          (ModalRoute.of(context)?.settings.arguments as String?) ??
          AppRoutes.brainResult;
      Navigator.pushReplacementNamed(context, route);
    });
  }

  @override
  void dispose() {
    _spin.dispose();
    _dots.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NFScreen(
      hideTabs: true,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Opacity(opacity: 0.9, child: NFMascot(size: 92, mood: MascotMood.calm)),
            const SizedBox(height: 24),
            RotationTransition(
              turns: _spin,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.blueSoft, width: 3.5),
                ),
                child: CustomPaint(painter: _ArcPainter()),
              ),
            ),
            const SizedBox(height: 18),
            AnimatedBuilder(
              animation: _dots,
              builder: (_, __) {
                final n = ((_dots.value * 3).floor() % 3) + 1;
                return Text(
                  'Gemma 4 processing${'.' * n}',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: (size.width / 2) - 1.75);
    canvas.drawArc(rect, -1.57, 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
