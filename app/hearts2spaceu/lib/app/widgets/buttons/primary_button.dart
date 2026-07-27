import 'package:flutter/material.dart';

/// The main call-to-action button — pill shape, solid brand fill.
///
/// Thin wrapper around [ElevatedButton] so it inherits `elevatedButtonTheme`
/// (Design System V1) while giving call sites a clear, named component.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return ElevatedButton(onPressed: onPressed, child: Text(label));
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
