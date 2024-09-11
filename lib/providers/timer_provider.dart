import 'dart:async';

import 'package:flutter/material.dart';

class TimerProvider with ChangeNotifier {
  Timer? _timer;
  DateTime _previousTime = DateTime.now();

  TimerProvider() {
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      final DateTime currentTime = DateTime.now();
      if(currentTime.minute != _previousTime.minute) {
        _previousTime = currentTime;
        notifyListeners();
      }
    });
  }

  void disposeTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
