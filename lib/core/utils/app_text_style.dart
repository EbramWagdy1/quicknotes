import 'package:flutter/material.dart';
import 'package:quicknotes/core/utils/app_colors.dart';

/// App typography and text styles defined in the Paper Slate design system (DESIGN (1).md).
abstract final class AppTextStyle {
  // Private constructor to prevent instantiation
  const AppTextStyle._();

  /// Standard font family for Paper Slate design system
  static const String fontFamily = 'Hanken Grotesk';

  // ---------------------------------------------------------------------------
  // Display Styles
  // ---------------------------------------------------------------------------

  /// Display Large (Desktop/Header): 36px, Bold (700), Line Height: 44px, Tracking: -0.02em
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 44 / 36,
    letterSpacing: -0.72,
    color: AppColors.slate900,
  );

  /// Display Large Mobile (Note Title Editor): 28px, Bold (700), Line Height: 36px, Tracking: -0.015em
  static const TextStyle displayLargeMobile = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
    letterSpacing: -0.42,
    color: AppColors.slate900,
  );

  // ---------------------------------------------------------------------------
  // Headline Styles
  // ---------------------------------------------------------------------------

  /// Headline Large: 24px, SemiBold (600), Line Height: 32px, Tracking: -0.01em
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
    letterSpacing: -0.24,
    color: AppColors.slate900,
  );

  /// Headline Medium (Empty states, section headers): 20px, SemiBold (600), Line Height: 28px, Tracking: -0.005em
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    letterSpacing: -0.10,
    color: AppColors.slate900,
  );

  /// Headline Small (Note list card title): 18px, SemiBold (600), Line Height: 24px
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    color: AppColors.slate900,
  );

  // ---------------------------------------------------------------------------
  // Body Styles
  // ---------------------------------------------------------------------------

  /// Body Large (Note body canvas reading): 16px, Regular (400), Line Height: 26px (~1.6x)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 26 / 16,
    color: AppColors.slate900,
  );

  /// Body Medium: 14px, Regular (400), Line Height: 22px
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 22 / 14,
    color: AppColors.slate600,
  );

  /// Body Small (Note snippet, helper texts): 13px, Regular (400), Line Height: 18px
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    color: AppColors.slate600,
  );

  // ---------------------------------------------------------------------------
  // Label & Metadata Styles
  // ---------------------------------------------------------------------------

  /// Label Large (Buttons, primary interactive controls): 14px, Medium (500), Line Height: 20px
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    color: AppColors.onPrimary,
  );

  /// Label Medium (Pills, Chips, Search Input): 12px, Medium (500), Line Height: 16px, Tracking: +0.01em
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.12,
    color: AppColors.slate600,
  );

  /// Label Small (Metadata tags, counters, timestamps): 11px, SemiBold (600), Line Height: 14px, Tracking: +0.02em
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 14 / 11,
    letterSpacing: 0.22,
    color: AppColors.slate400,
  );
}
