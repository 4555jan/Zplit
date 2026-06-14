import 'package:flutter/material.dart';

abstract class AppTheme {
  // Colors
  static const Color _primary = Color(0xFF7C3AED);
  static const Color _primaryLight = Color(0xFF9D68F0);
  static const Color _primaryDark = Color(0xFF5B21B6);
  static const Color _negative = Color(0xFFEF4444);
  static const Color _backgroundLight = Color(0xFFFFFFFF);
  static const Color _surfaceLight = Color(0xFFF5F3FF);
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _dividerLight = Color(0xFFE5E7EB);
  static const Color _textPrimaryLight = Color(0xFF111827);
  static const Color _textSecondaryLight = Color(0xFF6B7280);
  static const Color _textHintLight = Color(0xFF9CA3AF);
  static const Color _backgroundDark = Color(0xFF12111A);
  static const Color _surfaceDark = Color(0xFF1E1B2E);
  static const Color _cardDark = Color(0xFF252336);
  static const Color _dividerDark = Color(0xFF2E2B3E);
  static const Color _textPrimaryDark = Color(0xFFF9FAFB);
  static const Color _textSecondaryDark = Color(0xFFA0A0B0);
  static const Color _textHintDark = Color(0xFF6B6B80);

  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: _primary,
      primaryContainer: _primaryLight,
      secondary: _primaryDark,
      surface: _surfaceLight,
      error: _negative,
    ),
    scaffoldBackgroundColor: _backgroundLight,
    cardColor: _cardLight,
    dividerColor: _dividerLight,
    textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: _textPrimaryLight,
      ),
      displayMedium: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: _textPrimaryLight,
      ),
      headlineLarge: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: _textPrimaryLight,
      ),
      headlineMedium: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: _textPrimaryLight,
      ),
      headlineSmall: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _textPrimaryLight,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: _textPrimaryLight,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: _textSecondaryLight,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: _textHintLight,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: _textPrimaryLight,
      ),
      labelMedium: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: _textSecondaryLight,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: _textHintLight,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: _primary,
      primaryContainer: _primaryDark,
      secondary: _primaryLight,
      surface: _surfaceDark,
      error: _negative,
    ),
    scaffoldBackgroundColor: _backgroundDark,
    cardColor: _cardDark,
    dividerColor: _dividerDark,
    textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: _textPrimaryDark,
      ),
      displayMedium: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: _textPrimaryDark,
      ),
      headlineLarge: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: _textPrimaryDark,
      ),
      headlineMedium: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: _textPrimaryDark,
      ),
      headlineSmall: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _textPrimaryDark,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: _textPrimaryDark,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: _textSecondaryDark,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: _textHintDark,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: _textPrimaryDark,
      ),
      labelMedium: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: _textSecondaryDark,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: _textHintDark,
      ),
    ),
  );
}
