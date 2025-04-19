import 'dart:async';
import 'package:flutter/material.dart';

class StopwatchProvider extends ChangeNotifier {
  // Stopwatch state
  bool isRunning = false;
  int elapsedMilliseconds = 0;
  Timer? _timer;
  bool showTimer = false;
  
  // For managing lap times
  List<int> laps = [];
  
  // Recent laps for display
  List<int> get recentLaps {
    if (laps.isEmpty) return [];
    
    // Return last 3 laps or all if less than 3
    if (laps.length <= 3) {
      return laps.reversed.toList();
    } else {
      return laps.reversed.take(3).toList();
    }
  }
  
  // Check if we have more than 3 laps to display
  bool get hasMoreLaps => laps.length > 3;
  
  // Start or resume the stopwatch
  void start() {
    if (!isRunning) {
      isRunning = true;
      showTimer = true;
      
      // Start timer that ticks every 10ms for precision
      _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        elapsedMilliseconds += 10;
        notifyListeners();
      });
      
      notifyListeners();
    }
  }
  
  // Pause the stopwatch
  void pause() {
    if (isRunning) {
      isRunning = false;
      _timer?.cancel();
      _timer = null;
      notifyListeners();
    }
  }
  
  // Reset the stopwatch
  void reset() {
    pause();
    elapsedMilliseconds = 0;
    laps.clear();
    showTimer = false;
    notifyListeners();
  }
  
  // Add a lap time
  void addLap() {
    if (isRunning || elapsedMilliseconds > 0) {
      laps.add(elapsedMilliseconds);
      notifyListeners();
    }
  }
  
  // Format milliseconds to string
  String formatMilliseconds(int ms) {
    final milliseconds = ms % 1000;
    final seconds = (ms ~/ 1000) % 60;
    final minutes = (ms ~/ 60000) % 60;
    final hours = ms ~/ 3600000;
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${(milliseconds ~/ 10).toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${(milliseconds ~/ 10).toString().padLeft(2, '0')}';
    }
  }
  
  // Format elapsed time as mm:ss.ms
  String get formattedTime => formatMilliseconds(elapsedMilliseconds);
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
} 