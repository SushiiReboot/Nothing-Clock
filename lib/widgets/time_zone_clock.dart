import 'package:flutter/material.dart';
import 'package:nothing_clock/models/world_clock_data.dart';
import 'package:nothing_clock/providers/worldclocks_provider.dart';
import 'package:provider/provider.dart';

class TimeZoneClock extends StatefulWidget {
  final WorldClockData data;

  const TimeZoneClock({super.key, required this.data});

  @override
  _TimeZoneClockState createState() => _TimeZoneClockState();
}

class _TimeZoneClockState extends State<TimeZoneClock> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
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
                  widget.data.capital.toUpperCase(),
                  style: TextStyle(
                      fontSize: 16, color: theme.colorScheme.onTertiary),
                )
              ],
            ),
            Consumer<WorldClocksProvider>(
              builder: (context, value, child) {
                return Text(
                  widget.data.currentFormattedTime,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 33,
                    color: theme.colorScheme.onTertiary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
