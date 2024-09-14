// time_zone_clock.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nothing_clock/models/world_clock_data.dart';

class TimeZoneClock extends StatefulWidget {
  final WorldClockData data;

  const TimeZoneClock({Key? key, required this.data}) : super(key: key);

  @override
  _TimeZoneClockState createState() => _TimeZoneClockState();
}

class _TimeZoneClockState extends State<TimeZoneClock> {
  late DateTime _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    print("Initializing clock for ${widget.data.city}");
    if (widget.data.isDataReady) {
      _currentTime = widget.data.getCurrentTime();
      _scheduleNextUpdate();
    } else {
      // Data is not yet ready, add listener
      widget.data.addListener(_onDataChanged);
    }
  }

  void _onDataChanged() {
    if (widget.data.isDataReady) {
      widget.data.removeListener(_onDataChanged);
      setState(() {
        _currentTime = widget.data.getCurrentTime();
      });
      _scheduleNextUpdate();
    }
  }

  void _scheduleNextUpdate() {
    // Calculate duration until the next minute for this clock
    int secondsUntilNextMinute = 60 - _currentTime.second;
    int millisecondsUntilNextMinute =
        (secondsUntilNextMinute * 1000) - _currentTime.millisecond;

    // Schedule a timer to fire at the next minute change
    _timer = Timer(Duration(milliseconds: millisecondsUntilNextMinute), () {
      // Update the current time
      setState(() {
        _currentTime = widget.data.getCurrentTime();
      });

      // Schedule periodic updates every minute thereafter
      _timer = Timer.periodic(Duration(minutes: 1), (timer) {
        setState(() {
          _currentTime = widget.data.getCurrentTime();
        });
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('H:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    if (!widget.data.isDataReady) {
      // Data not ready, show loading indicator
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiary,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.red),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    widget.data.city.toUpperCase(),
                    style: TextStyle(
                        fontSize: 16, color: theme.colorScheme.onTertiary),
                  )
                ],
              ),
              Text(
                "00:00",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 33,
                  color: theme.colorScheme.onTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    print("Building clock for ${widget.data.city}. Time: $_currentTime");

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.red),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  widget.data.city.toUpperCase(),
                  style: TextStyle(
                      fontSize: 16, color: theme.colorScheme.onTertiary),
                )
              ],
            ),
            Text(
              _formatDateTime(_currentTime),
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 33,
                color: theme.colorScheme.onTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
