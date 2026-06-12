import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

abstract class AppTheme {
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.primaryDark,
      surface: AppColors.surfaceLight,
      error: AppColors.negative,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    cardColor: AppColors.cardLight,
    dividerColor: AppColors.dividerLight,
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      displayMedium: AppTextStyles.displayMedium.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      headlineLarge: AppTextStyles.headingLarge.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      headlineMedium: AppTextStyles.headingMedium.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      headlineSmall: AppTextStyles.headingSmall.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondaryLight,
      ),
      bodySmall: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textHintLight,
      ),
      labelLarge: AppTextStyles.labelLarge.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      labelMedium: AppTextStyles.labelMedium.copyWith(
        color: AppColors.textSecondaryLight,
      ),
      labelSmall: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textHintLight,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryDark,
      secondary: AppColors.primaryLight,
      surface: AppColors.surfaceDark,
      error: AppColors.negative,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    cardColor: AppColors.cardDark,
    dividerColor: AppColors.dividerDark,
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      displayMedium: AppTextStyles.displayMedium.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      headlineLarge: AppTextStyles.headingLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      headlineMedium: AppTextStyles.headingMedium.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      headlineSmall: AppTextStyles.headingSmall.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondaryDark,
      ),
      bodySmall: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textHintDark,
      ),
      labelLarge: AppTextStyles.labelLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      labelMedium: AppTextStyles.labelMedium.copyWith(
        color: AppColors.textSecondaryDark,
      ),
      labelSmall: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textHintDark,
      ),
    ),
  );
}
