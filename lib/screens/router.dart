import 'package:flutter/material.dart';
import 'package:nothing_clock/screens/alarms_screen.dart';
import 'package:nothing_clock/screens/clock_screen.dart';
import 'package:nothing_clock/screens/stopwatch_screen.dart';
import 'package:nothing_clock/screens/timer_screen.dart';
import 'package:nothing_clock/widgets/drawer_popup.dart';
import 'package:nothing_clock/widgets/top_bar.dart';
import 'package:provider/provider.dart';
import 'package:nothing_clock/providers/page_provider.dart'; // Import PageProvider

class Router extends StatefulWidget {
  const Router({super.key});

  @override
  State<Router> createState() => _RouterState();
}

class _RouterState extends State<Router> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Initialize PageController without an initial page
    // We'll set it based on the provider once the context is available
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  static const List<Widget> _screens = [
    ClockScreen(),
    AlarmsScreen(),
    TimerScreen(),
    StopwatchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        callback: (index) =>
            Provider.of<PageProvider>(context, listen: false).setPage(index),
        scaffoldKey: _scaffoldKey,
        selectedIndex: Provider.of<PageProvider>(context).selectedIndex,
      ),
      key: _scaffoldKey,
      endDrawer: const DrawerPopup(),

      // Use Consumer to rebuild the PageView when the page index changes
      body: Consumer<PageProvider>(
        builder: (context, pageProvider, child) {
          // Set the page immediately without animation when index changes
          if (_pageController.hasClients && 
              _pageController.page?.round() != pageProvider.selectedIndex) {
            _pageController.jumpToPage(pageProvider.selectedIndex);
          }

          return PageView(
            controller: _pageController,
            physics: const ClampingScrollPhysics(), // Smoother transitions
            onPageChanged: (index) {
              // Update the provider when the user swipes to a new page
              pageProvider.setPage(index);
            },
            children: _screens,
          );
        },
      ),
    );
  }
}
