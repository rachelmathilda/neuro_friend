import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum NFButtonVariant { primary, navy, success, coach, cream, ghost, pillSmall }

class NFButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final NFButtonVariant variant;
  final bool fullWidth;
  final bool small;
  final Widget? icon;

  const NFButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = NFButtonVariant.primary,
    this.fullWidth = false,
    this.small = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final spec = _spec(variant);
    final padding = variant == NFButtonVariant.pillSmall
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 7)
        : small
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 18, vertical: 14);
    final radius = variant == NFButtonVariant.pillSmall ? 999.0 : 14.0;
    final fontSize = variant == NFButtonVariant.pillSmall
        ? 12.0
        : small
            ? 12.5
            : 15.0;
    final fontWeight = (variant == NFButtonVariant.cream ||
            variant == NFButtonVariant.pillSmall)
        ? FontWeight.w700
        : FontWeight.w600;

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[icon!, const SizedBox(width: 6)],
        Text(
          label,
          style: TextStyle(
            color: spec.fg,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ],
    );

    return Material(
      color: spec.bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: spec.border != null
            ? BorderSide(color: spec.border!, width: 1.5)
            : BorderSide.none,
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          decoration: spec.shadow != null
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  boxShadow: [spec.shadow!],
                )
              : null,
          padding: padding,
          width: fullWidth ? double.infinity : null,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }

  _ButtonSpec _spec(NFButtonVariant v) {
    switch (v) {
      case NFButtonVariant.primary:
        return _ButtonSpec(
          bg: AppColors.blue,
          fg: Colors.white,
          shadow: BoxShadow(
            color: AppColors.blue.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        );
      case NFButtonVariant.navy:
        return const _ButtonSpec(bg: AppColors.navy, fg: Colors.white);
      case NFButtonVariant.success:
        return const _ButtonSpec(bg: AppColors.green, fg: AppColors.textPrimary);
      case NFButtonVariant.coach:
        return const _ButtonSpec(bg: AppColors.orange, fg: Colors.white);
      case NFButtonVariant.cream:
        return const _ButtonSpec(bg: AppColors.cream, fg: AppColors.creamAccent);
      case NFButtonVariant.ghost:
        return const _ButtonSpec(
          bg: Colors.transparent,
          fg: AppColors.textSecondary,
          border: AppColors.border,
        );
      case NFButtonVariant.pillSmall:
        return const _ButtonSpec(bg: AppColors.cream, fg: AppColors.creamAccent);
    }
  }
}

class _ButtonSpec {
  final Color bg;
  final Color fg;
  final Color? border;
  final BoxShadow? shadow;
  const _ButtonSpec({required this.bg, required this.fg, this.border, this.shadow});
}
