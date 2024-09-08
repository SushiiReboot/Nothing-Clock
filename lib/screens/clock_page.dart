import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nothing_clock/widgets/info_display_clock.dart';
import 'package:nothing_clock/widgets/time_zone_clock.dart';
import 'package:nothing_clock/widgets/top_bar.dart';
import 'package:nothing_clock/widgets/world_map.dart';

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: const TopBar(title: "Clock"),
      body: SafeArea(
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
                    text: "Sun, jul 23",
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
                          cityName: "Italy",
                        );
                      }))
            ],
          ),
        ),
      )),
    );
  }
}
