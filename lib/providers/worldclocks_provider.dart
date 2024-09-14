import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nothing_clock/models/world_clock_data.dart';
import 'package:http/http.dart' as http;
import 'package:nothing_clock/providers/timer_provider.dart';

class WorldClocksProvider with ChangeNotifier {
  List<WorldClockData> _worldClocks = [];

  List<WorldClockData> get worldClocks => _worldClocks;

  WorldClocksProvider(TimerProvider timerProvider) {
    _initWithTestData();
    _initialize(timerProvider);
  }

  Future<void> _initialize(TimerProvider timerProvider) async {
    await _fetchInitialTimeData(); // Wait for times to be fetched
    timerProvider.addListener(updateWorldClocks);
    notifyListeners(); // Notify listeners after data is ready
  }

// In WorldClocksProvider.dart
// In WorldClocksProvider.dart

  Future<void> _fetchInitialTimeData() async {
    for (var worldClock in _worldClocks) {
      final wc = worldClock; // Capture the variable
      final response = await _fetchTimeFromZone(wc.continent, wc.city);
      final jsonData = jsonDecode(response);

      DateTime apiDateTime = DateTime.parse(jsonData['dateTime']);
      DateTime fetchTime = DateTime.now();

      wc.initialDateTime = apiDateTime;
      wc.initialFetchTime = fetchTime;
      wc.currentDateTime = apiDateTime;
      wc.isDataReady = true; // Set data as ready

      print("Fetched time for ${wc.city}: ${wc.currentDateTime}");
      wc.notifyListeners();
    }
  }

// In WorldClocksProvider.dart
  void updateWorldClocks() {
    DateTime now = DateTime.now().toUtc();
    for (var worldClock in _worldClocks) {
      Duration elapsed = now.difference(worldClock.initialFetchTime);
      worldClock.currentDateTime = worldClock.initialDateTime.add(elapsed);
      worldClock.notifyListeners();
    }
  }

  Future<String> _fetchTimeFromZone(String continent, String city) async {
    print("Fetching time for $continent/$city");
    final response = await http.get(Uri.parse(
        'https://timeapi.io/api/time/current/zone?timeZone=$continent%2F$city'));

    if (response.statusCode == 200) {
      return response.body.toString();
    } else {
      throw Exception('Failed to load time');
    }
  }

  void _initWithTestData() {
    // Initialize with placeholder DateTime values
    DateTime placeholderTime = DateTime.now().toUtc();
    _worldClocks = [
      WorldClockData(
        city: "Rome",
        continent: "Europe",
        currentDateTime: placeholderTime,
        initialDateTime: placeholderTime,
        initialFetchTime: placeholderTime,
      ),
      WorldClockData(
        city: "Tokyo",
        continent: "Asia",
        currentDateTime: placeholderTime,
        initialDateTime: placeholderTime,
        initialFetchTime: placeholderTime,
      ),
    ];
  }

  void addWorldClock(WorldClockData worldClock) {
    _worldClocks.add(worldClock);
  }

  void removeWorldClock(WorldClockData worldClock) {
    _worldClocks.remove(worldClock);
  }
}
