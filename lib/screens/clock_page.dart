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
      bottomNavigationBar: BottomBar(theme: theme),
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
                          time: "12:21",
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

class BottomBar extends StatefulWidget {
  const BottomBar({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: widget.theme.colorScheme.surface,
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.red,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      showUnselectedLabels: true, // Show unselected labels as well
      items: const [
        BottomNavigationBarItem(icon: SizedBox.shrink(), label: "ALARMS"),
        BottomNavigationBarItem(icon: SizedBox.shrink(), label: "CLOCK"),
        BottomNavigationBarItem(icon: SizedBox.shrink(), label: "TIMER"),
        BottomNavigationBarItem(icon: SizedBox.shrink(), label: "STOPWATCH"),
      ],
    );
  }
}
