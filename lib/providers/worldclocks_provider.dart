import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nothing_clock/models/timezone_data.dart';
import 'package:nothing_clock/models/world_clock_data.dart';
import 'package:http/http.dart' as http;
import 'package:nothing_clock/providers/clock_provider.dart';
import 'package:provider/provider.dart';

/// This provider manages a list of world clocks and updates their times
/// based on a native event channel that emits time tick events.
class WorldClocksProvider with ChangeNotifier {
  List<WorldClockData> _worldClocks = [];

  List<WorldClockData> get worldClocks => _worldClocks;

    // Subscription to the time tick stream.
  StreamSubscription<dynamic>? _timeTickSubscription;

  WorldClocksProvider(BuildContext context) {
    _initialize();
    _subscribeToTimeTick(context);
  }

  /// Asynchronously initializes the world clocks by fetching their time data.
  Future<void> _initialize() async {
    await _fetchInitialTimeData(); // Wait for times to be fetched
    notifyListeners(); // Notify listeners after data is ready
  }

  Future<void> _fetchInitialTimeData() async {
    for (var worldClock in _worldClocks) {

      // Fetch the UTC offset for the given continent and capital.
      final response = await _fetchUtcTimezone(worldClock.latitude, worldClock.longitude);
      worldClock.utc = response.utcOffset;

      // Recalculate the clock's time offset based on the new UTC value and the standard UTC time.
      worldClock.calculateTimeOffset();
    }

    notifyListeners();
  }

  /// Subscribes to the shared clock event stream provided by ClockProvider.
  /// This method listens to the native time tick events and updates the clocks.
  void _subscribeToTimeTick(BuildContext context) {
    final clockProvider = Provider.of<ClockProvider>(context, listen: false);

    _timeTickSubscription = clockProvider.clockStream.listen((event) {
      debugPrint("Time tick event received: $event");
      updateWorldClocks();
    }, onError: (error) {
      debugPrint("Error receiving time tick event: $error");
    });
  }

  @override
  void dispose() {
    _timeTickSubscription?.cancel();
    super.dispose();
  }

  /// Updates all world clocks by recalculating their time offsets.
  /// Notifies listeners so that the UI can refresh.
  void updateWorldClocks() {
    for (var worldClock in _worldClocks) {
      worldClock.calculateTimeOffset();
    }

    notifyListeners();
  }

  /// Fetches the UTC timezone data for the given coordinates.
  /// Returns a TimezoneData object containing the UTC offset.
  Future<TimezoneData> _fetchUtcTimezone(double latitude, double longitude) async {
    try {
      final response = await http.get(Uri.parse(
        'http://api.geonames.org/timezoneJSON?lat=$latitude&lng=$longitude&username=sashachverenko'));

    
    debugPrint("Fetched time for $latitude/$longitude");
    final jsonData = jsonDecode(response.body);

    final int utcOffset = jsonData['gmtOffset'];

    return TimezoneData(
      utcOffset: utcOffset
    );
    } catch(e) {
      debugPrint("Error fetching time: $e");
      return TimezoneData(utcOffset: 0);
    }
  }

  /// Adds a new world clock to the list.
  void addWorldClock(WorldClockData worldClock) async {
    TimezoneData timezoneData = await _fetchUtcTimezone(worldClock.latitude, worldClock.longitude);
    worldClock.utc = timezoneData.utcOffset;
    worldClock.calculateTimeOffset();
    
    _worldClocks.add(worldClock);

    notifyListeners();
  }

  /// Removes a world clock from the list.
  void removeWorldClock(WorldClockData worldClock) {
    _worldClocks.remove(worldClock);
    notifyListeners();
  }
}
