import 'package:flutter/material.dart';

/// Design system color palette extracted from docs/DESIGN.md & docs/design HTML mockups.
class AppColors {
  AppColors._();

  // Primary palette (Mindful Sage Greens)
  static const Color primary = Color(0xFF3D6751);
  static const Color primaryContainer = Color(0xFFA8D5BA);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF345D48);
  static const Color primaryFixed = Color(0xFFBFEDD1);
  static const Color primaryFixedDim = Color(0xFFA4D1B6);
  static const Color onPrimaryFixedVariant = Color(0xFF254F3A);

  // Backgrounds & Canvas (Soft Bone White & Whitespace)
  static const Color backgroundCanvas = Color(0xFFFAFAFA);
  static const Color background = Color(0xFFFBF9F8);
  static const Color surface = Color(0xFFFBF9F8);
  static const Color surfaceRaised = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color surfaceContainer = Color(0xFFF3F4F6);
  static const Color surfaceContainerHigh = Color(0xFFEAE8E7);
  static const Color surfaceContainerHighest = Color(0xFFE4E2E1);

  // Text & Content
  static const Color onSurface = Color(0xFF1B1C1C);
  static const Color onSurfaceVariant = Color(0xFF414943);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color outline = Color(0xFF717973);
  static const Color outlineVariant = Color(0xFFC1C8C1);
  static const Color borderSubtle = Color(0xFFE5E7EB);

  // Energy Accents
  // High Focus (⚡ Deep Work / Urgent Calm Blue)
  static const Color highFocus = Color(0xFF0060AC);
  static const Color highFocusAccent = Color(0xFF4A90E2);
  static const Color highFocusContainer = Color(0xFFD4E3FF);
  static const Color highFocusContainerLight = Color(0xFFEBF3FF);
  static const Color onHighFocusContainer = Color(0xFF003E73);

  // Balanced / Medium Focus (⚖️ Regular Rhythm)
  static const Color mediumFocus = Color(0xFF414943);
  static const Color mediumFocusContainer = Color(0xFFE4E2E1);

  // Relaxed (🌿 Gentle / Warm Sunlight Yellow)
  static const Color relaxed = Color(0xFF765A00);
  static const Color relaxedAccent = Color(0xFFF5CA5C);
  static const Color relaxedContainer = Color(0xFFF0C658);
  static const Color relaxedContainerLight = Color(0xFFFFF6DD);
  static const Color onRelaxedContainer = Color(0xFF6B5200);
  static const Color tertiaryFixed = Color(0xFFFFDF96);
  static const Color onTertiaryFixedVariant = Color(0xFF594400);

  // Semantic
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
}
