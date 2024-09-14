// timer_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';

class TimerProvider with ChangeNotifier {
  Timer? _timer;

  TimerProvider();

  void startTimer() {
    // Cancel any existing timer
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      print("Timer tick");
      notifyListeners();
    });
  }

  void disposeTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
