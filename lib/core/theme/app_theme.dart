import 'package:flutter/material.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';

abstract final class AppTheme {
  const AppTheme._();

  // Dark Palette Tokens adhering to UI/UX Pro Max standards
  static const Color darkCanvas = Color(0xFF0F172A); // Deep slate canvas (Slate 900)
  static const Color darkCard = Color(0xFF1E293B); // Elevated card surface (Slate 800)
  static const Color darkBorder = Color(0xFF334155); // Subtle border (Slate 700)
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50 (contrast > 15:1)
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400 (contrast > 5:1)
  static const Color darkSkyBlue = Color(0xFF38BDF8); // Vibrant Sky Blue 400

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTextStyle.fontFamily,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.skyBlue,
        surface: AppColors.cardWhite,
        onSurface: AppColors.slate900,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.slate900),
        titleTextStyle: TextStyle(
          fontFamily: AppTextStyle.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.slate900,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cardWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.skyBlue,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: AppTextStyle.fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.slate900,
        ),
        headlineMedium: TextStyle(
          fontFamily: AppTextStyle.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.slate900,
        ),
        headlineSmall: TextStyle(
          fontFamily: AppTextStyle.fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.slate900,
        ),
        bodyLarge: TextStyle(
          fontFamily: AppTextStyle.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.slate900,
        ),
        bodyMedium: TextStyle(
          fontFamily: AppTextStyle.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.slate600,
        ),
        bodySmall: TextStyle(
          fontFamily: AppTextStyle.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.slate600,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTextStyle.fontFamily,
      scaffoldBackgroundColor: darkCanvas,
      colorScheme: const ColorScheme.dark(
        primary: darkSkyBlue,
        onPrimary: darkCanvas,
        secondary: darkSkyBlue,
        surface: darkCard,
        onSurface: darkTextPrimary,
        error: AppColors.destructive,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCanvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(
          fontFamily: AppTextStyle.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkSkyBlue,
        foregroundColor: darkCanvas,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: AppTextStyle.fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: AppTextStyle.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: AppTextStyle.fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: AppTextStyle.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: AppTextStyle.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkTextSecondary,
        ),
        bodySmall: TextStyle(
          fontFamily: AppTextStyle.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: darkTextSecondary,
        ),
      ),
    );
  }
}

/// Dynamic theme helper extension on [BuildContext]
extension ThemeContextExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  Color get surfaceColor => isDarkMode ? AppTheme.darkCard : AppColors.cardWhite;
  Color get canvasColor => isDarkMode ? AppTheme.darkCanvas : AppColors.canvas;
  Color get borderColor => isDarkMode ? AppTheme.darkBorder : AppColors.borderSubtle;
  Color get textPrimary => isDarkMode ? AppTheme.darkTextPrimary : AppColors.slate900;
  Color get textSecondary => isDarkMode ? AppTheme.darkTextSecondary : AppColors.slate600;
  Color get textMuted => isDarkMode ? AppTheme.darkTextSecondary.withValues(alpha: 0.7) : AppColors.slate400;
  Color get containerFill => isDarkMode ? AppTheme.darkCard : AppColors.surfaceContainerLow;
  Color get chipBackground => isDarkMode ? AppTheme.darkBorder : AppColors.surfaceContainerHigh;
  Color get iconColor => isDarkMode ? AppTheme.darkTextSecondary : AppColors.slate600;
  Color get glassSurface => isDarkMode ? const Color(0xFF1E293B).withValues(alpha: 0.72) : Colors.white.withValues(alpha: 0.82);
  Color get glassBorder => isDarkMode ? const Color(0xFF475569).withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.8);
  Color get glassPill => isDarkMode ? const Color(0xFF334155).withValues(alpha: 0.6) : const Color(0xFFF1F5F9).withValues(alpha: 0.85);
  Color get accentPill => isDarkMode ? AppTheme.darkSkyBlue.withValues(alpha: 0.18) : AppColors.skyBlueBackground.withValues(alpha: 0.85);
  Color get accentColor => isDarkMode ? AppTheme.darkSkyBlue : AppColors.primary;
}
