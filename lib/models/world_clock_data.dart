// ignore_for_file: public_member_api_docs, sort_constructors_first
// world_clock_data.dart
import 'package:flutter/material.dart';

class WorldClockData with ChangeNotifier {
  final String city;
  final String continent;
  DateTime currentDateTime;
  DateTime initialDateTime; // Time received from the API
  DateTime initialFetchTime; // Time when the API call was made
  bool isDataReady = false;

  WorldClockData({
    required this.city,
    required this.continent,
    required this.currentDateTime,
    required this.initialDateTime,
    required this.initialFetchTime,
  });

  DateTime getCurrentTime() {
    Duration elapsed = DateTime.now().toUtc().difference(initialFetchTime);
    return initialDateTime.add(elapsed);
  }
}
