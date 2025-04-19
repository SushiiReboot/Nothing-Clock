import 'package:flutter/material.dart';

class PageProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setPage(int index) {
    // Only update and notify if the index actually changed
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners(); // Notify listeners to rebuild UI
    }
  }
  
  // Direct navigation to specific pages
  void goToClockPage() => setPage(0);
  void goToAlarmsPage() => setPage(1);
  void goToTimerPage() => setPage(2);
  void goToStopwatchPage() => setPage(3);
}
