import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that listens to a clock event stream and updates the displayed time in real-time.
class ClockStreamWidget extends StatefulWidget {
  const ClockStreamWidget({super.key});

  @override
  State<ClockStreamWidget> createState() => _ClockStreamWidgetState();
}

class _ClockStreamWidgetState extends State<ClockStreamWidget> {
  /// EventChannel to listen for native clock events.
  static const _clockEventChannel = EventChannel("clockEventChannel");

  /// Stream of DateTime values representing the clock updates.
  late Stream<DateTime> _clockStream;

  @override
  void initState() {
    super.initState();

    // Initialize the stream to listen for clock events from the native platform.
    // The event received is in milliseconds since epoch, converted to a DateTime object.
    _clockStream = _clockEventChannel
        .receiveBroadcastStream()
        .map((event) => DateTime.fromMillisecondsSinceEpoch(event));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      // Listen to the clock event stream.
      stream: _clockStream,
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