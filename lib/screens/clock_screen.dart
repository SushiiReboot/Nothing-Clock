import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nothing_clock/widgets/time_zone_clock.dart';
import 'package:nothing_clock/widgets/world_map.dart';

import '../widgets/info_display_clock.dart';

class ClockScreen extends StatelessWidget {
  const ClockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat("EEE, MMM dd").format(now);

    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const WorldMap(),
            const SizedBox(
              height: 20,
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
                height: 1200,
                child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      return const TimeZoneClock(
                        time: "12:21",
                        cityName: "Italy",
                      );
                    }))
          ],
        ),
      ),
    ));
  }
}
