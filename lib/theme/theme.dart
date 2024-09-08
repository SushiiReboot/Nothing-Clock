import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData dark = ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.deepPurple,
      textTheme: const TextTheme(
          labelLarge: TextStyle(
              fontFamily: "Roboto", fontSize: 15, fontWeight: FontWeight.w400)),
      colorScheme: const ColorScheme.dark(
          surface: Colors.black,
          onSurface: Colors.white,
          primary: Color.fromARGB(212, 255, 26, 26),
          secondary: Color.fromARGB(215, 217, 216, 255),
          tertiary: Color(0xFF1D1E20),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onTertiary: Colors.white));
}
