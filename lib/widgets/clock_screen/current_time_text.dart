import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nothing_clock/providers/timer_provider.dart';
import 'package:provider/provider.dart';

class CurrentTimeText extends StatefulWidget {
  const CurrentTimeText({super.key});

  @override
  State<CurrentTimeText> createState() => _CurrentTimeTextState();
}

class _CurrentTimeTextState extends State<CurrentTimeText> {
  String _timeString = "00:00";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTime();
  }

  // Formatting the current DateTime to display hour and minute
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('H:mm').format(dateTime); // Example: "14:35"
  }

  // Update the displayed time if it has changed
  void _updateTime() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _timeString = _formatDateTime(DateTime.now());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    // Using Selector instead of Consumer for efficiency
    return Consumer<TimerProvider>(
      // No need to store time in provider
      builder: (context, currentTime, child) {
        // Update time only when necessary
        _updateTime();

        return Text(
          _timeString, // Display the formatted time
          style: theme.textTheme.titleLarge?.copyWith(fontSize: 72),
        );
      },
    );
  }
}
