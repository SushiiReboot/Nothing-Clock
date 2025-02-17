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
    _initWithTestData(); //TODO: Remove this after testing

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
      final response = await _fetchUtcTimezone(worldClock.continent, worldClock.capital);
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

  /// Fetches the UTC timezone data for the given continent and capital.
  /// Returns a TimezoneData object containing the UTC offset.
  Future<TimezoneData> _fetchUtcTimezone(String continent, String capital) async {
    try {
      final response = await http.get(Uri.parse(
        'http://worldtimeapi.org/api/timezone/$continent/$capital'));

    
    debugPrint("Fetched time for $continent/$capital");
    final jsonData = jsonDecode(response.body);

    final utcOffsetString = jsonData['utc_offset'].toString();

    // Determine if the offset is negative.
    final signValue = utcOffsetString.startsWith("-") ? -1 : 1;

    // Parse the hour portion of the UTC offset.
    final hours = int.parse(utcOffsetString.substring(1, 3));
    final utcOffset = signValue * hours;

    return TimezoneData(
      utcOffset: utcOffset,
    );
    } catch(e) {
      debugPrint("Error fetching time: $e");
      return TimezoneData(utcOffset: 0);
    }
  }

  /// Initializes the world clocks with test data.
  /// This data is for testing purposes and should be removed in production.
  void _initWithTestData() {    
    _worldClocks = [
      WorldClockData(
        capital: "Rome",
        continent: "Europe",
        utcTime: 0,
        currentFormattedTime: "00:00"
      ),
      WorldClockData(
        capital: "Tokyo",
        continent: "Asia",
        utcTime: 0,
        currentFormattedTime: "00:00"
      ),
    ];
  }

  /// Adds a new world clock to the list.
  void addWorldClock(WorldClockData worldClock) {
    _worldClocks.add(worldClock);
  }

  /// Removes a world clock from the list.
  void removeWorldClock(WorldClockData worldClock) {
    _worldClocks.remove(worldClock);
  }
}
