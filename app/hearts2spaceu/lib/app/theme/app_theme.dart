import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Builds the light/dark [ThemeData] used across the app.
///
/// Tweak typography, component themes, etc. here so styling stays in one place.
class AppTheme {
  const AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
      );
}
