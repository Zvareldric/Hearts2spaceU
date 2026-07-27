import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Shadow tokens — low, diffuse, navy-tinted (Proposal §5). Deliberately
/// softer than Material's default sharp elevation shadows.
class AppShadows {
  const AppShadows._();

  static List<BoxShadow> get sm => [
    BoxShadow(
      color: AppColors.ink.withValues(alpha: 0.05),
      offset: const Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  static List<BoxShadow> get md => [
    BoxShadow(
      color: AppColors.ink.withValues(alpha: 0.07),
      offset: const Offset(0, 8),
      blurRadius: 28,
    ),
  ];

  static List<BoxShadow> get lg => [
    BoxShadow(
      color: AppColors.ink.withValues(alpha: 0.09),
      offset: const Offset(0, 16),
      blurRadius: 40,
    ),
  ];
}
