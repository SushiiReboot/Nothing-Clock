import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:nothing_clock/models/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

class AlarmsService {

  List<Alarm>? _cachedAlarams;

  static const MethodChannel _channel = MethodChannel('com.example.nothing_clock');

  Future<bool> canScheduleExactAlarms() async {
    try {
      final bool? result = await _channel.invokeMethod("canScheduleExactAlarms");
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint("Error checking if exact alarms can be scheduled: $e");
      return false;
    }
  } 

  static Future<void> openExactAlarmSettings() async {
    try {
      await _channel.invokeMethod("openExactAlarmSettings");
    } on PlatformException catch (e) {
      debugPrint("Error opening exact alarm settings: $e");
    }
  }

  Future<void> saveAlarms(List<Map<String, dynamic>> alarms) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> alarmsStrings =
        alarms.map((alarm) => jsonEncode(alarm)).toList();
    await prefs.setStringList("alarms", alarmsStrings);
  }

  Future<void> saveAlarmData(Alarm alarm) async {
    final box = await Hive.openBox<Alarm>('alarms');
    await box.add(alarm); 

    loadAlarms();
  }

  Future<List<Alarm>> loadAlarms() async {
    if(_cachedAlarams != null) {
      return _cachedAlarams!;
    }

    final box = await Hive.openBox<Alarm>('alarms');
    _cachedAlarams = box.values.toList();
    return _cachedAlarams!;
  }

  static void alarmCallback() {
    // This code will run when the alarm triggers.
    debugPrint("Alarm triggered!");
  }

  Future<void> scheduleAlarmAt(Alarm alarm) async {
    await AndroidAlarmManager.oneShotAt(alarm.time, 0, alarmCallback, exact: true, wakeup: true);
  }
}
