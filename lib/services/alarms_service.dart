import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:nothing_clock/models/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmsService {

  List<Alarm>? _cachedAlarams;

  Future<void> saveAlarms(List<Map<String, dynamic>> alarms) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> alarmsStrings =
        alarms.map((alarm) => jsonEncode(alarm)).toList();
    await prefs.setStringList("alarms", alarmsStrings);
  }

  Future<void> saveAlarmData(Alarm alarm) async {
    final box = await Hive.openBox<Alarm>('alarms');
    await box.add(alarm); 

    loadAlarms(resetCache: true);
  }

  Future<List<Alarm>> loadAlarms({bool resetCache = false}) async {
    if(_cachedAlarams != null && !resetCache) {
      return _cachedAlarams!;
    }

    final box = await Hive.openBox<Alarm>('alarms');
    _cachedAlarams = box.values.toList();
    return _cachedAlarams!;
  }
}
