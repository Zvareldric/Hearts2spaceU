import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the light/dark [ThemeData] used across the app — Design System V1.
///
/// Centralizes the "calm companion" look (Design Proposal): soft radii, flat
/// diffuse surfaces (Material elevation kept at 0; depth comes from
/// `AppShadows` inside components), a large-title app bar, and the brand
/// color tokens from [AppColors].
class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.primaryStrong,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primary,
      onPrimaryContainer: AppColors.onPrimary,
      secondary: AppColors.secondaryStrong,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondary,
      onSecondaryContainer: AppColors.onPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      surfaceContainerHighest: AppColors.surfaceTint,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.outline,
    );

    return _themeFrom(
      colorScheme: colorScheme,
      textTheme: AppTypography.light,
      scaffoldBackground: AppColors.background,
      ink: AppColors.ink,
    );
  }

  static ThemeData get dark {
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnPrimary,
      primaryContainer: AppColors.darkPrimary,
      onPrimaryContainer: AppColors.darkOnPrimary,
      secondary: AppColors.darkSecondary,
      onSecondary: AppColors.darkOnPrimary,
      secondaryContainer: AppColors.darkSecondary,
      onSecondaryContainer: AppColors.darkOnPrimary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkInk,
      surfaceContainerHighest: AppColors.darkSurfaceTint,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.darkOutline,
    );

    return _themeFrom(
      colorScheme: colorScheme,
      textTheme: AppTypography.dark,
      scaffoldBackground: AppColors.darkBackground,
      ink: AppColors.darkInk,
    );
  }

  static ThemeData _themeFrom({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required Color scaffoldBackground,
    required Color ink,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: ink,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
          textStyle: textTheme.titleMedium,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurface,
        textColor: colorScheme.onSurface,
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outline, thickness: 1),
    );
  }
}
