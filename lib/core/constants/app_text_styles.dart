import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        fontStyle: fontStyle,
      );

  static TextStyle get headlineLarge =>
      _base(size: 26, weight: FontWeight.w800, letterSpacing: -0.4);

  static TextStyle get headlineMedium =>
      _base(size: 22, weight: FontWeight.w800, letterSpacing: -0.3);

  static TextStyle get titleLarge =>
      _base(size: 17, weight: FontWeight.w700);

  static TextStyle get titleMedium =>
      _base(size: 14, weight: FontWeight.w700);

  static TextStyle get bodyLarge => _base(size: 15, weight: FontWeight.w500);

  static TextStyle get bodyMedium => _base(size: 13.5, weight: FontWeight.w500);

  static TextStyle get bodySmall =>
      _base(size: 12, weight: FontWeight.w500, color: AppColors.textSecondary);

  static TextStyle get caption =>
      _base(size: 11, weight: FontWeight.w600, color: AppColors.textTertiary);
}
