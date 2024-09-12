import 'package:flutter/material.dart';
import 'package:nothing_clock/providers/timer_provider.dart';
import 'package:nothing_clock/screens/alarms_screen.dart';
import 'package:nothing_clock/screens/clock_screen.dart';
import 'package:nothing_clock/screens/stopwatch_screen.dart';
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
  final PageController _pageController = PageController(); // PageController

  static const List<Widget> _screens = [
    ClockScreen(),
    AlarmsScreen(),
    Placeholder(),
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
          // Delay the animation to ensure the widget is fully built and ready
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              if (pageProvider.selectedIndex != 0) {
                Provider.of<TimerProvider>(context, listen: false)
                    .disposeTimer();
              } else {
                Provider.of<TimerProvider>(context, listen: false).startTimer();
              }

              _pageController.animateToPage(
                pageProvider.selectedIndex,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
              );
            }
          });

          return PageView(
            controller: _pageController,
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
