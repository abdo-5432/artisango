import 'package:flutter/material.dart';

class ThemeConfig {
  static const Color primary = Color(0xFF6C63FF);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Poppins',
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark),
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
  );
}
