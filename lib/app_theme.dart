import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary     = Color(0xFFB85C38);
  static const Color primaryDark = Color(0xFF9A4A2A);
  static const Color background  = Color(0xFFF5F0E8);
  static const Color surface     = Color(0xFFFFFFFF);
  static const Color textDark    = Color(0xFF1C1712);
  static const Color textMuted   = Color(0xFF7A6A5A);
  static const Color divider     = Color(0xFFE8E0D5);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: primaryDark,
      surface: surface,
      onPrimary: Colors.white,
      onSurface: textDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: textDark,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: textMuted,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: divider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: divider)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: primary, width: 1.5)),
    ),
    dividerColor: divider,
  );
}
