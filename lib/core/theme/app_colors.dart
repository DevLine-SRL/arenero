import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // ── Base ──────────────────────────────────────────────
  static const Color primary = Color(0xFF6B3D18);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFE8D5C4);
  static const Color onPrimaryContainer = Color(0xFF3E2723);

  static const Color secondary = Color(0xFF7D5A3C);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFF0E6D6);
  static const Color onSecondaryContainer = Color(0xFF3E2723);

  static const Color tertiary = Color(0xFF5A7D6B);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // ── Surface ───────────────────────────────────────────
  static const Color background = Color(0xFFF5EFE2);
  static const Color surface = Color(0xFFFDF9F2);
  // static const Color surfaceVariant = Color(0xFFEDE3CF);
  static const Color onSurface = Color(0xFF3E2723);
  static const Color onSurfaceVariant = Color(0xFF5D4037);

  // ── Semantic ──────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  // static const Color success = Color(0xFF2E7D32);
  // static const Color warning = Color(0xFFE65100);
  // static const Color info = Color(0xFF1565C0);

  // ── Misc ──────────────────────────────────────────────
  static const Color outline = Color(0xFFC4B5A5);
  // static const Color divider = Color(0xFFE0D6C8);
}
