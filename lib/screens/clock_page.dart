import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nothing_clock/widgets/bottom_bar.dart';
import 'package:nothing_clock/widgets/drawer_popup.dart';
import 'package:nothing_clock/widgets/info_display_clock.dart';
import 'package:nothing_clock/widgets/time_zone_clock.dart';
import 'package:nothing_clock/widgets/top_bar.dart';
import 'package:nothing_clock/widgets/world_map.dart';
import 'package:intl/intl.dart';

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat("EEE, MMM dd").format(now);

    return Scaffold(
      bottomNavigationBar: BottomBar(theme: theme),
      appBar: TopBar(title: "Clock", scaffoldKey: _scaffoldKey),
      key: _scaffoldKey,
      endDrawer: const DrawerPopup(),
      floatingActionButton: _buildAddMoreBtn(theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
      )),
    );
  }

  Padding _buildAddMoreBtn(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: InkWell(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(50)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: const Text(
            "ADD MORE",
            style: TextStyle(letterSpacing: 1.5),
          ),
        ),
      ),
    );
  }
}
