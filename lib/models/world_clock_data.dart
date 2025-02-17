// ignore_for_file: public_member_api_docs, sort_constructors_first
// world_clock_data.dart
import 'package:flutter/material.dart';

class WorldClockData with ChangeNotifier {
  final String capital;
  final String continent;

  int utcTime;
  String currentFormattedTime;

  set utc(int value) {
    if (value < -12) {
      utcTime = -12;
      notifyListeners();
      return;
    } else if (value > 14) {
      utcTime = 14;
      notifyListeners();
      return;
    }

    utcTime = value;
    notifyListeners();
  }

  int get utc => utcTime;

  void calculateTimeOffset() {
    DateTime localTime = DateTime.now().toUtc();

    int hour = localTime.hour + utcTime;
    int minutes = localTime.minute;

    //The hour ranges from 00 to 23. If the hour is negative, we need to wrap it around.
    int wrappedHour = (hour % 24 + 24) % 24;

    currentFormattedTime = "${(wrappedHour).toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")}";
    debugPrint("UTC Time: $localTime. Offset: $utcTime");
  }

  WorldClockData({
    required this.currentFormattedTime,
    required this.utcTime,
    required this.capital,
    required this.continent,
  });
}
