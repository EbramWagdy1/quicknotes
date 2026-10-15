import 'package:flutter/material.dart';

/// App color palette defined in the Paper Slate design system (DESIGN (1).md).
abstract final class AppColors {
  // Private constructor to prevent instantiation
  const AppColors._();

  // ---------------------------------------------------------------------------
  // Material 3 / Core Tokens
  // ---------------------------------------------------------------------------
  static const Color primary = Color(0xFF0284C7); // Sky Blue 600
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF0EA5E9); // Sky Blue 500
  static const Color onPrimaryContainer = Color(0xFF0C4A6E); // Sky Blue 900
  static const Color inversePrimary = Color(0xFF7DD3FC);
  static const Color primaryFixed = Color(0xFFE0F2FE); // Sky Blue 100
  static const Color primaryFixedDim = Color(0xFFBAE6FD); // Sky Blue 200
  static const Color onPrimaryFixed = Color(0xFF0369A1); // Sky Blue 700
  static const Color onPrimaryFixedVariant = Color(0xFF0284C7);

  // Active / Pressed States for Primary
  static const Color primaryActive = Color(0xFF0369A1);

  // Secondary Tokens
  static const Color secondary = Color(0xFF0284C7);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF38BDF8);
  static const Color onSecondaryContainer = Color(0xFF0C4A6E);
  static const Color secondaryFixed = Color(0xFFE0F2FE);
  static const Color secondaryFixedDim = Color(0xFFBAE6FD);
  static const Color onSecondaryFixed = Color(0xFF0369A1);
  static const Color onSecondaryFixedVariant = Color(0xFF0284C7);
  static const Color secondaryLight = Color(0xFF38BDF8);

  // Tertiary Tokens (Semantic Ambient / Sky Blue)
  static const Color tertiary = Color(0xFF004D70);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF006693);
  static const Color onTertiaryContainer = Color(0xFFB8E0FF);
  static const Color tertiaryFixed = Color(0xFFC9E6FF);
  static const Color tertiaryFixedDim = Color(0xFF89CEFF);
  static const Color onTertiaryFixed = Color(0xFF001E2F);
  static const Color onTertiaryFixedVariant = Color(0xFF004C6E);

  // Tertiary Semantic Ambient Indicators (Sky Blue)
  static const Color skyBlue = Color(0xFF0EA5E9);
  static const Color skyBlueBackground = Color(0xFFE0F2FE);

  // Surface & Background Tokens
  static const Color background = Color(0xFFF8F9FF);
  static const Color onBackground = Color(0xFF0B1C30);
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceDim = Color(0xFFCBDBF5);
  static const Color surfaceBright = Color(0xFFF8F9FF);
  static const Color surfaceVariant = Color(0xFFD3E4FE);
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF464555);
  static const Color inverseSurface = Color(0xFF213145);
  static const Color inverseOnSurface = Color(0xFFEAF1FF);

  // Surface Containers (Tonal Elevation Tiers)
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);

  // Surface Tint & Outlines
  static const Color surfaceTint = Color(0xFF4D44E3);
  static const Color outline = Color(0xFF777587);
  static const Color outlineVariant = Color(0xFFC7C4D8);

  // Error & Destructive Semantics
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color destructive = Color(0xFFEF4444);

  // Success / Saved Status
  static const Color success = Color(0xFF10B981);

  // ---------------------------------------------------------------------------
  // Slate Paper Neutrals & Typography Colors
  // ---------------------------------------------------------------------------
  static const Color canvas = Color(0xFFF8FAFC);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color borderHover = Color(0xFFCBD5E1);
  static const Color dragHandle = Color(0xFFCBD5E1);

  static const Color slate900 = Color(0xFF0F172A); // Primary Headlines & Text
  static const Color slate800 = Color(0xFF1E293B); // Dark slate neutral
  static const Color slate700 = Color(0xFF334155); // Slate neutral icons & secondary headers
  static const Color slate600 = Color(
    0xFF475569,
  ); // Subheadings & Body descriptions
  static const Color slate500 = Color(0xFF64748B); // Muted neutral
  static const Color slate400 = Color(
    0xFF94A3B8,
  ); // Tertiary timestamps & hints
  static const Color slate300 = Color(0xFFCBD5E1); // Subtle borders & placeholders
  static const Color slate200 = Color(0xFFE2E8F0); // Subtle background accents
  static const Color slate100 = Color(0xFFF1F5F9); // Chip & Search Background

  // ---------------------------------------------------------------------------
  // Overlays & Ambient Shadows
  // ---------------------------------------------------------------------------
  static const Color modalBackdrop = Color(
    0x590F172A,
  ); // rgba(15, 23, 42, 0.35)

  // Box Shadows
  static const List<BoxShadow> tier1Shadow = [
    BoxShadow(
      color: Color(0x0A0F172A), // rgba(15, 23, 42, 0.04)
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
    BoxShadow(
      color: Color(0x050F172A), // rgba(15, 23, 42, 0.02)
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> tier2Shadow = [
    BoxShadow(
      color: Color(0x0F0F172A), // rgba(15, 23, 42, 0.06)
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x0A0F172A), // rgba(15, 23, 42, 0.04)
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> tier3Shadow = [
    BoxShadow(
      color: Color(0x2E4F46E5), // rgba(79, 70, 229, 0.18)
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color(0x1A4F46E5), // rgba(79, 70, 229, 0.1)
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> modalSheetShadow = [
    BoxShadow(
      color: Color(0x1F0F172A), // rgba(15, 23, 42, 0.12)
      offset: Offset(0, -8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];
}
