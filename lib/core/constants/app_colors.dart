import 'package:flutter/material.dart';

/// App color palette - Blue theme for elder-friendly billing app
class AppColors {
  AppColors._();

  // Primary Blue Theme
  static const Color primary = Color.fromARGB(255, 30, 124, 218);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color.fromARGB(255, 36, 106, 211);
  static const Color primaryAccent = Color(0xFF90CAF9);

  // Secondary Colors
  static const Color secondary = Color(0xFF1565C0);
  static const Color secondaryLight = Color(0xFF42A5F5);
  static const Color secondaryDark = Color(0xFF003C8F);

  // Background Colors - Light Mode
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Background Colors - Dark Mode
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2C2C2C);

  // Text Colors - Light Mode
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textHintLight = Color(0xFFBDBDBD);

  // Text Colors - Dark Mode
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textHintDark = Color(0xFF757575);

  // Status Colors
  static const Color success = Color(0xFF1B8F3A);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Payment Mode Colors
  static const Color cash = Color(0xFF2E7D32);
  static const Color upi = Color(0xFF7B1FA2);
  static const Color credit = Color(0xFFE65100);

  // Destructive Action Button
  static const Color destructiveBackground = Color(0xFFFFEDD5);
  static const Color destructiveIcon = Color(0xFFD32F2F);

  // Accent Button (QTY/Rate mode toggle)
  static const Color accentBackground = Color(0xFFE7F2FD);
  static const Color accentBorder = Color(0xFF1976D2);
  static const Color accentText = Color(0xFF1976D2);

  // High Contrast Colors
  static const Color contrastBackground = Color(0xFF000000);
  static const Color contrastSurface = Color(0xFF1A1A1A);
  static const Color contrastText = Color(0xFFFFFFFF);
  static const Color contrastPrimary = Color(0xFF00B0FF);
  static const Color contrastBorder = Color(0xFFFFFFFF);

  // Keypad Colors
  static const Color keypadButton = Color(0xFFE3F2FD);
  static const Color keypadButtonDark = Color(0xFF263242);
  static const Color keypadText = Color(0xFF212121);
  static const Color keypadTextDark = Color(0xFFE8E8E8);

  // Divider
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);
}
