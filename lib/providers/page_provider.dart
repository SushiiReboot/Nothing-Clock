import 'package:flutter/material.dart';

class PageProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setPage(int index) {
    _selectedIndex = index;
    notifyListeners(); // Notify listeners to rebuild UI
  }
}
