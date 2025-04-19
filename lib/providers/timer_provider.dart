import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:audioplayers/audioplayers.dart';

/// A provider that manages the timer state and ensures it persists
/// when navigating between screens and when the app is closed.
class TimerProvider with ChangeNotifier {
  // Timer properties
  int _totalSeconds = 6 * 60 + 4; // Default: 6:04
  int _remainingSeconds = 6 * 60 + 4;
  int _originalTotalSeconds = 6 * 60 + 4;
  bool _isRunning = false;
  bool _isCompleted = false;
  bool _isPickerMode = false;
  
  // Timer start timestamp for persistence
  DateTime? _startTimestamp;
  DateTime? _pauseTimestamp;
  
  // Timer sound
  AudioPlayer? _audioPlayer;
  
  // Timer for UI updates
  Timer? _uiTimer;
  
  // Timer picker duration
  Duration _pickerDuration = const Duration(hours: 0, minutes: 6, seconds: 4);
  
  // Timer ID for the background service
  static const int _timerId = 4242;
  
  // Constructor - loads timer state from preferences
  TimerProvider() {
    _audioPlayer = AudioPlayer();
    _loadTimerState();
    _setupTimerCallback();
  }
  
  // Getters
  int get totalSeconds => _totalSeconds;
  int get remainingSeconds => _remainingSeconds;
  int get originalTotalSeconds => _originalTotalSeconds;
  bool get isRunning => _isRunning;
  bool get isCompleted => _isCompleted;
  bool get isPickerMode => _isPickerMode;
  Duration get pickerDuration => _pickerDuration;
  
  /// Setup timer callback for background service
  void _setupTimerCallback() {
    // Register a port for communication with background isolate
    final ReceivePort port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, 'timer_port');
    
    // Listen for messages from the background service
    port.listen((dynamic message) {
      if (message is Map) {
        if (message.containsKey('backgroundTick')) {
          // Background tick received, update the timer
          updateRemainingTime();
        }
      }
    });
  }
  
  /// Update the remaining time based on the elapsed time
  void updateRemainingTime() {
    if (_isRunning && !_isCompleted && _startTimestamp != null) {
      final elapsedSeconds = DateTime.now().difference(_startTimestamp!).inSeconds;
      _remainingSeconds = _totalSeconds - elapsedSeconds;
      
      // Check if timer has completed
      if (_remainingSeconds <= 0) {
        _remainingSeconds = 0;
        _onTimerComplete();
      }
      
      notifyListeners();
    }
  }
  
  /// Load timer state from shared preferences
  Future<void> _loadTimerState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load basic timer properties
      _totalSeconds = prefs.getInt('timer_total_seconds') ?? _totalSeconds;
      _originalTotalSeconds = prefs.getInt('timer_original_total_seconds') ?? _originalTotalSeconds;
      _isCompleted = prefs.getBool('timer_is_completed') ?? false;
      _remainingSeconds = prefs.getInt('timer_remaining_seconds') ?? _totalSeconds;
      
      // Load active state
      final wasRunning = prefs.getBool('timer_is_running') ?? false;
      
      // Only restore active timer if it was running
      if (wasRunning && !_isCompleted) {
        // Load timestamps for active timer
        final startMs = prefs.getInt('timer_start_timestamp');
        
        if (startMs != null) {
          _startTimestamp = DateTime.fromMillisecondsSinceEpoch(startMs);
          
          // Calculate current remaining time based on elapsed time
          final elapsedSeconds = DateTime.now().difference(_startTimestamp!).inSeconds;
          _remainingSeconds = _totalSeconds - elapsedSeconds;
          
          // Check if timer should have completed while app was closed
          if (_remainingSeconds <= 0) {
            _isCompleted = true;
            _isRunning = false;
            _remainingSeconds = 0;
          } else {
            // Resume the timer
            _isRunning = true;
            _startTimerInBackground();
          }
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading timer state: $e');
    }
  }
  
  /// Save timer state to shared preferences
  Future<void> _saveTimerState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save basic timer properties
      await prefs.setInt('timer_total_seconds', _totalSeconds);
      await prefs.setInt('timer_remaining_seconds', _remainingSeconds);
      await prefs.setInt('timer_original_total_seconds', _originalTotalSeconds);
      await prefs.setBool('timer_is_running', _isRunning);
      await prefs.setBool('timer_is_completed', _isCompleted);
      
      // Only save the start timestamp if the timer is running
      if (_isRunning && _startTimestamp != null) {
        await prefs.setInt('timer_start_timestamp', _startTimestamp!.millisecondsSinceEpoch);
      } else {
        await prefs.remove('timer_start_timestamp');
      }
      
      // We don't need to save the pause timestamp anymore
      await prefs.remove('timer_pause_timestamp');
    } catch (e) {
      debugPrint('Error saving timer state: $e');
    }
  }
  
  /// Background timer callback
  static void _backgroundTimerCallback() {
    // Send a message to the main isolate to update the timer
    final SendPort? sendPort = IsolateNameServer.lookupPortByName('timer_port');
    if (sendPort != null) {
      sendPort.send({'backgroundTick': true});
    }
  }
  
  /// Start the timer in background
  void _startTimerInBackground() {
    // Set start timestamp if not set
    _startTimestamp ??= DateTime.now();
    _pauseTimestamp = null;
    
    // Setup periodic background timer
    AndroidAlarmManager.periodic(
      const Duration(seconds: 1),
      _timerId,
      _backgroundTimerCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
    
    // Start a foreground timer for UI updates
    _startUiTimer();
    
    _saveTimerState();
  }
  
  /// Start a foreground timer for updating the UI
  void _startUiTimer() {
    // Cancel any existing timer
    _uiTimer?.cancel();
    
    // Create a new timer that fires every second
    _uiTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isRunning && !_isCompleted) {
        updateRemainingTime();
      } else {
        // Stop the timer if we're not running
        timer.cancel();
      }
    });
  }
  
  /// Start the timer
  void startTimer() {
    // When starting from a paused state, create a new start timestamp
    // based on the current remaining time
    _startTimestamp = DateTime.now().subtract(Duration(seconds: _totalSeconds - _remainingSeconds));
    _pauseTimestamp = null;
    _isRunning = true;
    
    // Start background and UI timers
    _startTimerInBackground();
    notifyListeners();
  }
  
  /// Pause the timer
  void pauseTimer() {
    _isRunning = false;
    
    // Store the remaining seconds directly, don't rely on timestamps when paused
    _pauseTimestamp = null;
    
    // Stop all timers
    _uiTimer?.cancel();
    AndroidAlarmManager.cancel(_timerId);
    
    // Save the current state
    _saveTimerState();
    notifyListeners();
  }
  
  /// Toggle timer between running and paused
  void toggleTimer() {
    if (_isCompleted) {
      snoozeTimer();
      return;
    }
    
    if (_isRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }
  
  /// Reset the timer
  void resetTimer() {
    _isRunning = false;
    _isCompleted = false;
    _remainingSeconds = _totalSeconds;
    _startTimestamp = null;
    _pauseTimestamp = null;
    _uiTimer?.cancel();
    AndroidAlarmManager.cancel(_timerId);
    _saveTimerState();
    notifyListeners();
  }
  
  /// Handle timer completion
  void _onTimerComplete() {
    if (_isCompleted) return; // Prevent duplicate completion
    
    _isCompleted = true;
    _isRunning = false;
    _uiTimer?.cancel();
    
    // Play sound
    try {
      _audioPlayer?.play(AssetSource('sounds/alarm.mp3'));
      _audioPlayer?.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
    
    _saveTimerState();
    notifyListeners();
  }
  
  /// Snooze the timer
  void snoozeTimer() {
    // Stop alarm
    try {
      _audioPlayer?.stop();
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
    
    // Reset timer state
    _isCompleted = false;
    _isRunning = false;
    _remainingSeconds = _totalSeconds;
    _startTimestamp = null;
    _pauseTimestamp = null;
    
    _uiTimer?.cancel();
    AndroidAlarmManager.cancel(_timerId);
    _saveTimerState();
    notifyListeners();
  }
  
  /// Add or subtract time
  void adjustTime(int secondsToAdjust) {
    final wasRunning = _isRunning;
    
    if (wasRunning) {
      pauseTimer();
    }
    
    // Use a large but safe maximum integer instead of infinity
    const int maxSafeSeconds = 100 * 60 * 60; // 100 hours in seconds
    
    // If we're adjusting time, we need to update both total and remaining seconds
    int newTotalSeconds = (_totalSeconds + secondsToAdjust).clamp(0, maxSafeSeconds);
    int newRemainingSeconds = _remainingSeconds + secondsToAdjust;
    
    // Check if the timer would go negative
    if (newRemainingSeconds <= 0 && !_isCompleted) {
      // Timer is hitting zero - trigger completion
      _totalSeconds = newTotalSeconds.clamp(1, maxSafeSeconds);
      _remainingSeconds = 0;
      _originalTotalSeconds = _totalSeconds;
      _onTimerComplete();
    } else {
      // Normal adjustment
      _totalSeconds = newTotalSeconds;
      _remainingSeconds = newRemainingSeconds.clamp(0, maxSafeSeconds);
      _originalTotalSeconds = _totalSeconds;
    }
    
    _saveTimerState();
    
    if (wasRunning && _remainingSeconds > 0) {
      startTimer();
    } else {
      notifyListeners();
    }
  }
  
  /// Toggle picker mode
  void togglePickerMode() {
    if (_isCompleted) {
      snoozeTimer();
    }
    
    _isPickerMode = !_isPickerMode;
    
    if (!_isPickerMode) {
      // User selected a time, update the timer
      _totalSeconds = _pickerDuration.inSeconds;
      _remainingSeconds = _totalSeconds;
      _originalTotalSeconds = _totalSeconds;
      
      // Reset the timer
      _startTimestamp = null;
      _pauseTimestamp = null;
      
      // If timer was running, restart with new duration
      if (_isRunning) {
        pauseTimer();
        startTimer();
      }
    } else {
      // User is entering picker mode, pause the timer
      if (_isRunning) {
        pauseTimer();
      }
      
      // Update picker with current timer value
      _pickerDuration = Duration(seconds: _remainingSeconds);
    }
    
    _saveTimerState();
    notifyListeners();
  }
  
  /// Update picked duration
  void updatePickerDuration(Duration duration) {
    _pickerDuration = duration;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _uiTimer?.cancel();
    AndroidAlarmManager.cancel(_timerId);
    _audioPlayer?.dispose();
    super.dispose();
  }
} 