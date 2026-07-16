import 'package:flutter/material.dart';

/// Palet warna Neo-Brutalism Lecto
class AppColors {
  AppColors._();

  // ─── Background ──────────────────────────────────────────────────────────
  static const Color bgPrimary = Color(0xFF0A0A0A);
  static const Color bgSecondary = Color(0xFF141414);
  static const Color bgCard = Color(0xFF1C1C1C);
  static const Color bgCardAlt = Color(0xFF222222);

  // ─── Accent ──────────────────────────────────────────────────────────────
  static const Color neonLime = Color(0xFFCCFF00);
  static const Color electricBlue = Color(0xFF00D4FF);
  static const Color purple = Color(0xFF9B59FF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF0F0F0);
  static const Color neonPink = Color(0xFFFF2D78);
  static const Color neonOrange = Color(0xFFFF6B00);

  // ─── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);

  // ─── Border ───────────────────────────────────────────────────────────────
  static const Color border = Color(0xFF333333);
  static const Color borderAccent = Color(0xFFCCFF00);

  // ─── Status ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF00FF88);
  static const Color error = Color(0xFFFF3333);
  static const Color warning = Color(0xFFFFCC00);

  // ─── Schedule Card Colors (7 unique colors) ────────────────────────────────
  static const List<Color> scheduleColors = [
    Color(0xFFCCFF00), // Neon Lime
    Color(0xFF00D4FF), // Electric Blue
    Color(0xFF9B59FF), // Purple
    Color(0xFFFF6B00), // Orange
    Color(0xFFFF2D78), // Pink
    Color(0xFF00FFCC), // Cyan
    Color(0xFFFF4444), // Red
  ];

  /// Returns schedule color by index (cycles if index > 6)
  static Color scheduleColorAt(int index) {
    return scheduleColors[index % scheduleColors.length];
  }

  /// Returns a dark version of the schedule color for text background
  static Color scheduleBgAt(int index) {
    final base = scheduleColorAt(index);
    return Color.fromARGB(30, base.red, base.green, base.blue);
  }
}
