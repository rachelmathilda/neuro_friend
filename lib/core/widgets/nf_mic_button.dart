import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class NFMicButton extends StatefulWidget {
  final double size;
  final Color color;
  final bool recording;
  final VoidCallback? onTap;

  const NFMicButton({
    super.key,
    this.size = 104,
    this.color = AppColors.blue,
    this.recording = false,
    this.onTap,
  });

  @override
  State<NFMicButton> createState() => _NFMicButtonState();
}

class _NFMicButtonState extends State<NFMicButton>
    with TickerProviderStateMixin {
  late final AnimationController _c1;
  late final AnimationController _c2;

  @override
  void initState() {
    super.initState();
    _c1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat();
    _c2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) _c2.repeat();
    });
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outer = widget.size + 80;
    return SizedBox(
      width: outer,
      height: outer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.recording) ...[
            _ring(_c1, 0.16),
            _ring(_c2, 0.08),
          ],
          GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.33),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                widget.recording ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: widget.recording ? 32 : 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ring(AnimationController c, double startOpacity) {
    return AnimatedBuilder(
      animation: c,
      builder: (_, __) {
        final t = c.value;
        final scale = 1 + t * 0.7;
        return Opacity(
          opacity: (1 - t) * startOpacity * 3.3,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: widget.color, width: 2),
              ),
            ),
          ),
        );
      },
    );
  }
}
