import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// High contrast theme for accessibility - thicker borders, higher contrast colors
ThemeData contrastTheme({double textScale = 1.0}) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Color Scheme - High Contrast
    colorScheme: const ColorScheme.dark(
      primary: AppColors.contrastPrimary,
      primaryContainer: AppColors.contrastPrimary,
      secondary: AppColors.contrastPrimary,
      secondaryContainer: AppColors.contrastPrimary,
      surface: AppColors.contrastSurface,
      error: Color(0xFFFF5252),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: AppColors.contrastText,
      onError: Colors.black,
    ),

    // Scaffold Background
    scaffoldBackgroundColor: AppColors.contrastBackground,

    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.contrastBackground,
      foregroundColor: AppColors.contrastText,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: AppSizes.fontSizeXLarge * textScale,
        fontWeight: FontWeight.bold,
        color: AppColors.contrastText,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.contrastText,
        size: AppSizes.iconSizeLarge,
      ),
    ),

    // Card Theme - Visible borders
    cardTheme: CardThemeData(
      color: AppColors.contrastSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: const BorderSide(color: AppColors.contrastBorder, width: 2),
      ),
    ),

    // Elevated Button Theme - Strong contrast
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.contrastPrimary,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, AppSizes.buttonHeightLarge),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingXLarge,
          vertical: AppSizes.paddingLarge,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          side: const BorderSide(color: AppColors.contrastText, width: 2),
        ),
        textStyle: TextStyle(
          fontSize: AppSizes.fontSizeXLarge * textScale,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.contrastPrimary,
        textStyle: TextStyle(
          fontSize: AppSizes.fontSizeLarge * textScale,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.contrastPrimary,
        side: const BorderSide(color: AppColors.contrastPrimary, width: 3),
        minimumSize: const Size(double.infinity, AppSizes.buttonHeightLarge),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingXLarge,
          vertical: AppSizes.paddingLarge,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        textStyle: TextStyle(
          fontSize: AppSizes.fontSizeXLarge * textScale,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // Input Decoration Theme - High visibility borders
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.contrastSurface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingXLarge,
        vertical: AppSizes.paddingLarge,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: const BorderSide(color: AppColors.contrastBorder, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: const BorderSide(color: AppColors.contrastBorder, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.contrastPrimary,
          width: 3,
        ),
      ),
      labelStyle: TextStyle(
        fontSize: AppSizes.fontSizeLarge * textScale,
        fontWeight: FontWeight.bold,
        color: AppColors.contrastText,
      ),
      hintStyle: TextStyle(
        fontSize: AppSizes.fontSizeLarge * textScale,
        color: AppColors.contrastText.withValues(alpha: 0.7),
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.contrastBorder,
      thickness: 2,
      space: AppSizes.spacingLarge,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.contrastSurface,
      labelStyle: TextStyle(
        fontSize: AppSizes.fontSizeMedium * textScale,
        fontWeight: FontWeight.bold,
        color: AppColors.contrastPrimary,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.spacingSmall,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        side: const BorderSide(color: AppColors.contrastPrimary, width: 2),
      ),
    ),

    // List Tile Theme
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingXLarge,
        vertical: AppSizes.paddingMedium,
      ),
      titleTextStyle: TextStyle(
        fontSize: AppSizes.fontSizeXLarge * textScale,
        fontWeight: FontWeight.bold,
        color: AppColors.contrastText,
      ),
      subtitleTextStyle: TextStyle(
        fontSize: AppSizes.fontSizeLarge * textScale,
        color: AppColors.contrastText.withValues(alpha: 0.8),
      ),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.contrastSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXLarge),
        ),
        side: BorderSide(color: AppColors.contrastBorder, width: 2),
      ),
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.contrastPrimary,
      contentTextStyle: TextStyle(
        fontSize: AppSizes.fontSizeLarge * textScale,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: const BorderSide(color: AppColors.contrastText, width: 2),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // Text Theme - Bold and large for accessibility
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: AppSizes.fontSizeDisplayLarge * textScale * 1.1,
        fontWeight: FontWeight.bold,
        color: AppColors.contrastText,
      ),
      displayMedium: TextStyle(
        fontSize: AppSizes.fontSizeDisplay * textScale * 1.1,
        fontWeight: FontWeight.bold,
        color: AppColors.contrastText,
      ),
      headlineLarge: TextStyle(
        fontSize: AppSizes.fontSizeXXLarge * textScale,
        fontWeight: FontWeight.bold,
        color: AppColors.contrastText,
      ),
      headlineMedium: TextStyle(
        fontSize: AppSizes.fontSizeXLarge * textScale,
        fontWeight: FontWeight.bold,
        color: AppColors.contrastText,
      ),
      titleLarge: TextStyle(
        fontSize: AppSizes.fontSizeLarge * textScale,
        fontWeight: FontWeight.bold,
        color: AppColors.contrastText,
      ),
      titleMedium: TextStyle(
        fontSize: AppSizes.fontSizeMedium * textScale,
        fontWeight: FontWeight.bold,
        color: AppColors.contrastText,
      ),
      bodyLarge: TextStyle(
        fontSize: AppSizes.fontSizeLarge * textScale,
        fontWeight: FontWeight.w500,
        color: AppColors.contrastText,
      ),
      bodyMedium: TextStyle(
        fontSize: AppSizes.fontSizeMedium * textScale,
        fontWeight: FontWeight.w500,
        color: AppColors.contrastText,
      ),
      bodySmall: TextStyle(
        fontSize: AppSizes.fontSizeSmall * textScale,
        fontWeight: FontWeight.w500,
        color: AppColors.contrastText.withValues(alpha: 0.8),
      ),
      labelLarge: TextStyle(
        fontSize: AppSizes.fontSizeMedium * textScale,
        fontWeight: FontWeight.bold,
        color: AppColors.contrastText,
      ),
    ),
  );
}
