import 'package:flutter/material.dart';

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
