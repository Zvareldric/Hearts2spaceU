import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Shadow tokens — low, diffuse, violet-tinted (Design System V2). Deliberately
/// softer than Material's default sharp elevation shadows: a glass pane casts a
/// colored haze, not a hard drop.
class AppShadows {
  const AppShadows._();

  static List<BoxShadow> get sm => [
    BoxShadow(
      color: AppColors.shadowTint.withValues(alpha: 0.10),
      offset: const Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  static List<BoxShadow> get md => [
    BoxShadow(
      color: AppColors.shadowTint.withValues(alpha: 0.14),
      offset: const Offset(0, 8),
      blurRadius: 28,
    ),
  ];

  static List<BoxShadow> get lg => [
    BoxShadow(
      color: AppColors.shadowTint.withValues(alpha: 0.22),
      offset: const Offset(0, 12),
      blurRadius: 32,
    ),
  ];
}
