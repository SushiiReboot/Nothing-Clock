import 'package:flutter/material.dart';
import 'package:nothing_clock/screens/alarms_screen.dart';
import 'package:nothing_clock/screens/clock_screen.dart';
import 'package:nothing_clock/screens/stopwatch_screen.dart';
import 'package:nothing_clock/widgets/drawer_popup.dart';
import 'package:nothing_clock/widgets/top_bar.dart';

class Router extends StatefulWidget {
  const Router({super.key});

  @override
  State<Router> createState() => _RouterState();
}

class _RouterState extends State<Router> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<Widget> _screens = [
    ClockScreen(),
    AlarmsScreen(),
    Placeholder(),
    StopwatchScreen(),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    void onNavBarTap(index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
        appBar: TopBar(
          callback: (index) => onNavBarTap(index),
          scaffoldKey: _scaffoldKey,
        ),
        key: _scaffoldKey,
        endDrawer: const DrawerPopup(),
        body: _screens.elementAt(_selectedIndex));
  }
}
