import 'package:flutter/material.dart';

abstract final class PlayColors {
  static const ink = Color(0xFF28204B);
  static const muted = Color(0xFF837E9B);
  static const purple = Color(0xFF7955D7);
  static const violet = Color(0xFFA18CF5);
  static const pink = Color(0xFFFF81B3);
  static const mint = Color(0xFF51C8B8);
  static const amber = Color(0xFFFFC66B);
  static const canvas = Color(0xFFF8F7FD);
  static const paleViolet = Color(0xFFF0EBFF);
}

ThemeData playNestTheme() {
  final colors = ColorScheme.fromSeed(
    seedColor: PlayColors.purple,
    brightness: Brightness.light,
  ).copyWith(
    primary: PlayColors.purple,
    secondary: PlayColors.mint,
    surface: Colors.white,
    onSurface: PlayColors.ink,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colors,
    scaffoldBackgroundColor: PlayColors.canvas,
    appBarTheme: const AppBarThemeData(
      backgroundColor: PlayColors.canvas,
      foregroundColor: PlayColors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w900, color: PlayColors.ink, letterSpacing: -1,
      ),
      titleLarge: TextStyle(fontWeight: FontWeight.w800, color: PlayColors.ink),
      titleMedium: TextStyle(fontWeight: FontWeight.w800, color: PlayColors.ink),
      bodyMedium: TextStyle(color: PlayColors.ink),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: PlayColors.purple, width: 1.5),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: PlayColors.ink,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
