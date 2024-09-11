import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nothing_clock/providers/location_provider.dart';
import 'package:nothing_clock/widgets/time_zone_clock.dart';
import 'package:nothing_clock/widgets/world_map.dart';
import 'package:provider/provider.dart';
import 'package:worldtime/worldtime.dart';

import '../widgets/info_display_clock.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat("EEE, MMM dd").format(now);

    double cellPadding = 10;
    double clockContainerSize =
        (MediaQuery.of(context).size.width - 40 - cellPadding) / 2;

    const List<String> testCitiesNames = ["Italy", "New York", "Tokyo"];
    const List<String> testCitiesClocks = ["12:21", "06:21", "20:21"];

    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              LocationInfo(),
              const SizedBox(
                height: 40,
              ),
              const WorldMap(),
              const SizedBox(
                height: 40,
              ),
              Row(
                children: [
                  InfoDisplayClock(
                    foregroundColor: Colors.white,
                    color: theme.colorScheme.tertiary,
                    text: formattedDate,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  InfoDisplayClock(
                    color: theme.colorScheme.secondary,
                    foregroundColor: Colors.black,
                    text: "1 alarm",
                    icon: FontAwesomeIcons.chevronRight,
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                  height: clockContainerSize * 2 + 120,
                  child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return TimeZoneClock(
                          time: testCitiesClocks[index],
                          cityName: testCitiesNames[index],
                        );
                      }))
            ],
          ),
        ),
      )),
    );
  }
}

class LocationInfo extends StatefulWidget {
  const LocationInfo({
    super.key,
  });

  @override
  State<LocationInfo> createState() => _LocationInfoState();
}

class _LocationInfoState extends State<LocationInfo> {
  String offset = "";

  Future<String> _getTimeZoneOffset(LocationProvider location) async {
    if (location.currentPosition?.latitude != null &&
        location.currentPosition?.longitude != null) {
      final value = await Worldtime().timeByLocation(
        latitude: location.currentPosition!.latitude,
        longitude: location.currentPosition!.longitude,
      );
      return "${value.timeZoneOffset.inHours > 0 ? "+" : ""}${value.timeZoneOffset.inHours}";
    }
    return "0"; // Default offset if location is not available
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CurrentTimeText(),
        const SizedBox(
          height: 10,
        ),
        Consumer<LocationProvider>(builder: (context, location, _) {
          return FutureBuilder(
            future: _getTimeZoneOffset(location),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final offset = snapshot.data ?? "0";
                print("TES");
                return Column(
                  children: [
                    Text(
                      "${location.currentAddress?.locality} | UTC $offset",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "${location.currentPosition?.latitude}, ${location.currentPosition?.longitude}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    )
                  ],
                );
              }
            },
          );
        }),
      ],
    );
  }
}

class CurrentTimeText extends StatefulWidget {
  const CurrentTimeText({
    super.key,
  });

  @override
  State<CurrentTimeText> createState() => _CurrentTimeTextState();
}

class _CurrentTimeTextState extends State<CurrentTimeText> {
  late String _timeString;
  late Timer _timer;

  @override
  void initState() {
    _timeString = _formatDateTime(DateTime.now());
    _timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());

    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('H:mm').format(dateTime);
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    if (mounted) {
      setState(() {
        _timeString = _formatDateTime(now);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Text(
      _timeString,
      style: theme.textTheme.titleLarge?.copyWith(fontSize: 72),
    );
  }
}
