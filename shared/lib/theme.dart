import 'package:flutter/material.dart';

class AppTheme {
  // Global Feedback Colors
  static const Color success = Color(0xFF12B76A);
  static const Color warning = Color(0xFFF79009);
  static const Color error = Color(0xFFD92D20);

  // Trainer App Theme (#E50914 Primary Red)
  static ThemeData trainerTheme = ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFFE50914),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFE50914),
      primary: const Color(0xFFE50914),
      error: error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ), // H2 Semi-bold
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ), // H1 24sp Semi-bold
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ), // H2 20sp Semi-bold
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ), // Body 16sp Regular
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ), // Body 14sp Regular
    ),
  );

  // Guru App Theme (#1769E0 Primary Blue)
  static ThemeData guruTheme = ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFF1769E0),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1769E0),
      primary: const Color(0xFF1769E0),
      error: error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ), // H2 Semi-bold
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ), // H1 24sp Semi-bold
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ), // H2 20sp Semi-bold
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ), // Body 16sp Regular
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ), // Body 14sp Regular
    ),
  );
}
