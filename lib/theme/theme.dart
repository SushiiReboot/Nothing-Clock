import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData dark = ThemeData(
      brightness: Brightness.dark,
      textTheme: const TextTheme(
          labelSmall: TextStyle(
              fontFamily: "Roboto",
              fontSize: 11,
              fontWeight: FontWeight.w100,
              color: Color.fromARGB(255, 255, 255, 255)),
          labelLarge: TextStyle(
              fontFamily: "Roboto", fontSize: 15, fontWeight: FontWeight.w400),
          labelMedium: TextStyle(
              fontFamily: "Roboto", fontSize: 12, fontWeight: FontWeight.w100),
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

  static final ThemeData light = ThemeData(
      brightness: Brightness.light,
      textTheme: const TextTheme(
          labelSmall: TextStyle(
              fontFamily: "Roboto",
              fontSize: 11,
              fontWeight: FontWeight.w100,
              color: Color.fromARGB(255, 22, 22, 22)),
          labelLarge: TextStyle(
              fontFamily: "Roboto", fontSize: 15, fontWeight: FontWeight.w400),
          labelMedium: TextStyle(
              fontFamily: "Roboto", fontSize: 12, fontWeight: FontWeight.w100),
          titleLarge: TextStyle(fontFamily: "NDot", fontSize: 25)),
      colorScheme: const ColorScheme.light(
          surface: Color.fromARGB(255, 230, 228, 215),
          onSurface: Colors.black,
          primary: Color.fromARGB(255, 255, 26, 26),
          secondary: Color.fromARGB(255, 233, 142, 58),
          tertiary: Color(0xFF1D1E20),
          onPrimary: Colors.black,
          onSecondary: Color.fromARGB(255, 0, 0, 0),
          onTertiary: Colors.white));
}
