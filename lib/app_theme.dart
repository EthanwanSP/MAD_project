import 'package:flutter/material.dart';

const Color kBlush = Color(0xFFFFCACB);
const Color kPeach = Color(0xFFFFC09D);
const Color kInk = Color(0xFF181818);
const Color kPaper = Color(0xFFFFFFFF);

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: kInk,
    onPrimary: kPaper,
    secondary: kPeach,
    onSecondary: kInk,
    error: Colors.redAccent,
    onError: kPaper,
    surface: kPaper,
    onSurface: kInk,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: kPaper,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: kInk,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kPaper,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: kInk.withOpacity(0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: kInk.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kInk, width: 1.4),
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: kInk),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kInk),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kInk),
      bodyMedium: TextStyle(fontSize: 14, color: kInk),
      bodySmall: TextStyle(fontSize: 12, color: kInk),
    ),
    useMaterial3: true,
  );
}
