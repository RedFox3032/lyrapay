import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const _fontFamily = 'GeneralSans';
  static const _monoFamily = 'GeneralSansMono';

  static const balanceLarge = TextStyle(
    fontFamily: _monoFamily,
    fontSize: 56,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: -1.5,
    height: 1.0,
  );

  static const balanceMedium = TextStyle(
    fontFamily: _monoFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: -1.0,
  );

  static const numpadDigit = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0,
  );

  static const voucherCode = TextStyle(
    fontFamily: _monoFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.neonGreen,
    letterSpacing: 2.0,
  );

  static const h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: -0.5,
  );

  static const h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: -0.3,
  );

  static const h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );

  static const buttonText = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    letterSpacing: 0.1,
  );

  static const lyraTag = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.neonGreen,
  );
}
