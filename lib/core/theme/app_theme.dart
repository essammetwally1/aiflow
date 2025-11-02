import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFf8ad0c);
  static const Color gray = Color(0xFF7B7B7B);
  static const Color backgroundLight = Color(0xFFFDFCF9);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color black = Color(0xFF1C1C1C);
  static const Color red = Color(0xFFFF5659);
  static const Color green = Colors.green;
  static const Color white = Colors.white;
  static const Color blue = Colors.blue;

  static ThemeData lightTheme = ThemeData(
    // useMaterial3: false,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      foregroundColor: primary,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 22,
        color: primary,
      ),
      iconTheme: IconThemeData(size: 30, color: primary),
      elevation: 0,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
    scaffoldBackgroundColor: backgroundLight,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: backgroundLight,
      shape: CircleBorder(),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: primary,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: white,
      unselectedItemColor: gray,
    ),
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: primary,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      contentPadding: const EdgeInsets.all(12),
      hintStyle: const TextStyle(
        fontSize: 16,
        color: gray,
        fontWeight: FontWeight.w500,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: red),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: black,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: black,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: black,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,

        color: black,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          decoration: TextDecoration.underline,
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    // useMaterial3: false,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      foregroundColor: primary,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 22,
        color: primary,
      ),
      iconTheme: IconThemeData(size: 30, color: primary),
      elevation: 0,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
    scaffoldBackgroundColor: backgroundDark,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: backgroundDark,
      foregroundColor: white,
      shape: CircleBorder(),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: Colors.transparent,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: white,
      unselectedItemColor: white,
    ),
    bottomAppBarTheme: BottomAppBarThemeData(
      color: primary.withValues(alpha: .5),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      contentPadding: const EdgeInsets.all(12),
      hintStyle: const TextStyle(
        fontSize: 16,
        color: white,
        fontWeight: FontWeight.w500,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: red),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: white,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: white,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: white,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          decoration: TextDecoration.underline,
        ),
      ),
    ),
  );
}
