import 'package:flutter/material.dart';

const Color kBlush = Color(0xFFFAD9D8);
const Color kPeach = Color(0xFFF6B9B3);
const Color kInk = Color(0xFF2B2B2B);
const Color kPaper = Color(0xFFFFFBFA);
const Color kSky = Color(0xFFD6E9FF);

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
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: kInk,
      indicatorColor: kPaper.withOpacity(0.18),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(color: kPaper, fontWeight: FontWeight.w600);
        }
        return TextStyle(color: kPaper.withOpacity(0.7), fontWeight: FontWeight.w500);
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: kPaper);
        }
        return IconThemeData(color: kPaper.withOpacity(0.7));
      }),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: kInk,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: kInk.withOpacity(0.06)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: kInk.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
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
