import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  String get currentTheme => _isDarkMode ? 'Dark' : 'Light';

  ThemeProvider() {
    loadThemeFromPreferences();
  }

  void initializeTheme(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    _isDarkMode = brightness == Brightness.dark;
    notifyListeners();
  }

  bool get isDarkMode => _isDarkMode;

  Future<bool> loadThemeFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();

    return _isDarkMode;
  }

  Future<void> _saveThemeToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemeToPreferences();
    notifyListeners();
  }
}
