import 'package:flutter/material.dart';
import 'package:nothing_clock/providers/clock_provider.dart';
import 'package:provider/provider.dart';

/// A widget that listens to a clock event stream and updates the displayed time in real-time.
class ClockStreamWidget extends StatefulWidget {
  const ClockStreamWidget({super.key});

  @override
  State<ClockStreamWidget> createState() => _ClockStreamWidgetState();
}

class _ClockStreamWidgetState extends State<ClockStreamWidget> {
  @override
  Widget build(BuildContext context) {
    final clockProvider = Provider.of<ClockProvider>(context);

    return StreamBuilder<DateTime>(
      // Listen to the clock event stream.
      stream: clockProvider.clockStream,
      builder: (context, snapshot) {
        // Show a loading indicator if no data is available yet.
        if (!snapshot.hasData) return const CircularProgressIndicator();

        // Extract the current time from the snapshot.
        final time = snapshot.data!;

        // Format the time as HH:mm (e.g., 14:05)
        final formattedDate = "${time.hour.toString().padLeft(2, "0")}:${time.minute.toString().padLeft(2, "0")}";

        // Display the formatted time with custom styling.
        return Text(
          formattedDate,
          style: const TextStyle(fontSize: 60, fontFamily: "NDot"),
        );
      },
      // Provide an initial value to avoid null issues.
      initialData: DateTime.now(),
    );
  }
}