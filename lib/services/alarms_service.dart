import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AlarmsService {
  Future<void> saveAlarms(List<Map<String, dynamic>> alarms) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> alarmsStrings =
        alarms.map((alarm) => jsonEncode(alarm)).toList();
    await prefs.setStringList("alarms", alarmsStrings);
  }

  Future<List<Map<String, dynamic>>> loadAlarms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> alarmsStrings = prefs.getStringList("alarms") ?? [];
    return alarmsStrings
        .map((alarmStr) => jsonDecode(alarmStr) as Map<String, dynamic>)
        .toList();
  }
}
