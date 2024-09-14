import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nothing_clock/models/world_clock_data.dart';
import 'package:nothing_clock/providers/location_provider.dart';
import 'package:nothing_clock/providers/page_provider.dart';
import 'package:nothing_clock/providers/theme_provider.dart';
import 'package:nothing_clock/providers/worldclocks_provider.dart';
import 'package:nothing_clock/widgets/clock_screen/current_time_text.dart';
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

    const List<String> testCitiesNames = ["Rome", "Tokyo"];
    const List<String> testContinents = ["Europe", "Asia"];

    final pageProvider = Provider.of<PageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const LocationInfo(),
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
                    outlineColor: themeProvider.isDarkMode
                        ? null
                        : theme.colorScheme.onSurface,
                    color: themeProvider.isDarkMode
                        ? theme.colorScheme.secondary
                        : Colors.transparent,
                    foregroundColor: theme.colorScheme.onSecondary,
                    text: "1 alarm",
                    icon: FontAwesomeIcons.chevronRight,
                    onTap: () {
                      print("Go to alarms");
                      pageProvider.setPage(1);
                    },
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
                    itemCount: 2,
                    // In ClockScreen.dart
                    itemBuilder: (context, index) {
                      return ChangeNotifierProvider<WorldClockData>.value(
                        value: Provider.of<WorldClocksProvider>(context)
                            .worldClocks[index],
                        child: TimeZoneClock(
                          data: Provider.of<WorldClocksProvider>(context)
                              .worldClocks[index],
                        ),
                      );
                    },
                  ))
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
    ThemeData theme = Theme.of(context);

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

                if (location.currentAddress?.locality == null ||
                    location.currentPosition?.latitude == null ||
                    location.currentPosition?.longitude == null ||
                    offset == "0") {
                  return LoadingAnimationWidget.horizontalRotatingDots(
                      color: theme.colorScheme.onSurface, size: 15);
                }

                return Column(
                  children: [
                    Text(
                      "${location.currentAddress?.locality} | UTC $offset",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "${location.currentPosition?.latitude}, ${location.currentPosition?.longitude}",
                      style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.8)),
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
