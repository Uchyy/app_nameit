import 'package:flutter/material.dart';

class NominoTheme {
  // Core color constants
  static const Color primary = Color(0xFF8A6FB3);
  static const Color secondary = Color(0xFFE2B96A);
  static const Color background = Color(0xFFFDFCFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF6A6A6A);
  static const Color titleColor = Color(0xFF4C3A75);
  static const Color timerColor = Color(0xFFE46C5D);
  

  // Base brand colors (from icon)
  static const Color pink = Color(0xFFFF4EAE);
  static const Color orange = Color(0xFFFFA24B);
  static const Color yellow = Color(0xFFFFD860);
  static const Color teal = Color(0xFF4FC7C0);
  static const Color blue = Color(0xFF3C90E8);

  // 🌈 Main app gradient (smooth blend, softer saturation)
  static const LinearGradient mainGradient = LinearGradient(
    colors: [
      pink,
      orange,
      yellow,
      teal,
      blue,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  // Simplified softer gradient (great for buttons or cards)
  static const LinearGradient softGradient = LinearGradient(
    colors: [
      Color(0xFFB88FD6), // soft purple
      Color(0xFFF9B87A), // peachy orange
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Example usage in button themes or containers
  static BoxDecoration gradientBox = const BoxDecoration(
    gradient: mainGradient,
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  // Light theme
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surface,
      surfaceContainerHighest: background,
      onPrimary: Colors.white,
      onSurface: textPrimary,
      onSurfaceVariant: textPrimary,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: titleColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textSecondary),
      titleLarge: TextStyle(
        color: titleColor,
        fontWeight: FontWeight.w600,
        fontSize: 22,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      titleTextStyle: const TextStyle(
        color: titleColor,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      contentTextStyle: const TextStyle(color: textPrimary),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

  );
}
