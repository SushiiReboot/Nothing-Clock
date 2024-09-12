import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeZoneClock extends StatefulWidget {
  const TimeZoneClock({
    super.key,
    required this.cityName,
  });

  final String cityName;

  @override
  State<TimeZoneClock> createState() => _TimeZoneClockState();
}

class _TimeZoneClockState extends State<TimeZoneClock> {
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('H:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
          color: theme.colorScheme.tertiary,
          borderRadius: BorderRadius.circular(15)),
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
                  widget.cityName.toUpperCase(),
                  style: TextStyle(
                      fontSize: 16, color: theme.colorScheme.onTertiary),
                )
              ],
            ),
            Text(
              "00:00",
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontSize: 33, color: theme.colorScheme.onTertiary),
            )
          ],
        ),
      ),
    );
  }
}
