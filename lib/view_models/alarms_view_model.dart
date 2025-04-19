import 'package:flutter/foundation.dart';
import 'package:nothing_clock/models/alarm.dart';
import 'package:nothing_clock/services/alarms_service.dart';

/// A view model that handles business logic for the alarms screen.
/// This separates the business logic from the UI representation.
class AlarmsViewModel with ChangeNotifier {
  /// Service that handles persistence and scheduling of alarms
  final AlarmsService _alarmsService = AlarmsService();
  
  /// The collection of user-created alarms
  List<Alarm> _alarms = [];
  
  /// Public getter for the alarms collection
  List<Alarm> get alarms => _alarms;

  /// Sleep time state and days (preset configuration)
  final DateTime _sleepTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 15);
  final List<String> _sleepDays = ["MON", "TUE", "WED"];
  bool _isSleepEnabled = false;

  /// Getters for sleep time configuration
  DateTime get sleepTime => _sleepTime;
  List<String> get sleepDays => _sleepDays;
  bool get isSleepEnabled => _isSleepEnabled;
  
  /// Sets the sleep time enabled state
  void toggleSleepEnabled() {
    _isSleepEnabled = !_isSleepEnabled;
    notifyListeners();
  }

  /// Loads alarms from persistent storage
  Future<void> loadAlarms() async {
    // Retrieve alarms from the service
    _alarms = await _alarmsService.loadAlarms();
    
    // Notify any listeners (like the UI) that data has changed
    notifyListeners();
  }

  /// Adds a new alarm and persists it
  Future<void> addAlarm(Alarm newAlarm) async {
    // Save alarm to persistent storage
    await _alarmsService.saveAlarmData(newAlarm);
    
    // Reload alarms list to include the new alarm
    await loadAlarms();
  }

  /// Toggles the enabled state of an alarm
  void toggleAlarmState(Alarm alarm) {
    // Toggle the enabled state
    alarm.isEnabled = !alarm.isEnabled;
    
    // Schedule or cancel the alarm based on the new state
    if (alarm.isEnabled) {
      _alarmsService.scheduleAlarmAt(alarm);
    } else {
      _alarmsService.cancelAlarm(alarm);
    }
    
    // Save the updated state
    alarm.save();
    
    // Refresh UI
    notifyListeners();
  }
} 