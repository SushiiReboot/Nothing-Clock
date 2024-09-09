import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData dark = ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.deepPurple,
      textTheme: const TextTheme(
          labelLarge: TextStyle(
              fontFamily: "Roboto", fontSize: 15, fontWeight: FontWeight.w400),
          titleLarge: TextStyle(fontFamily: "NDot", fontSize: 25)),
      colorScheme: const ColorScheme.dark(
          surface: Colors.black,
          onSurface: Colors.white,
          primary: Color.fromARGB(255, 255, 26, 26),
          secondary: Color.fromARGB(255, 233, 233, 250),
          tertiary: Color(0xFF1D1E20),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onTertiary: Colors.white));
}
