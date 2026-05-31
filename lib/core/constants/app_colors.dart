import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const neonGreen    = Color(0xFF00D632);
  static const neonGreenDim = Color(0xFF00A827);

  static const black        = Color(0xFF0A0A0A);
  static const card         = Color(0xFF1C1C1E);
  static const cardElevated = Color(0xFF2C2C2E);
  static const bottomSheet  = Color(0xFF131313);

  static const white        = Color(0xFFFFFFFF);
  static const textPrimary  = Color(0xFFFFFFFF);
  static const textSecondary= Color(0xFF8E8E93);
  static const textTertiary = Color(0xFF48484A);

  static const success      = Color(0xFF00D632);
  static const error        = Color(0xFFFF3B30);
  static const warning      = Color(0xFFFF9500);
  static const info         = Color(0xFF0A84FF);

  static const border       = Color(0xFF2C2C2E);
  static const borderActive = Color(0xFF00D632);

  static const numpadKey    = Color(0xFF1C1C1E);
  static const numpadKeyPressed = Color(0xFF2C2C2E);

  static const balanceGradient = LinearGradient(
    colors: [Color(0xFF00D632), Color(0xFF00FF3E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
