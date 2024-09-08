import 'package:flutter/material.dart';

class TimeZoneClock extends StatelessWidget {
  const TimeZoneClock({
    super.key,
    required this.cityName,
  });

  final String cityName;

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
                Text(cityName.toUpperCase())
              ],
            )
          ],
        ),
      ),
    );
  }
}
