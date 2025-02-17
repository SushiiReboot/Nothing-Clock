import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A provider that exposes a shared stream of time tick events from the native platform.
/// It uses an EventChannel to receive events and converts them into DateTime objects.
class ClockProvider extends ChangeNotifier {
  
  // Define an EventChannel that responds to time system tick events.
  static const EventChannel _timeTickEventChannel = EventChannel('clockEventChannel');

  // A stream that emits DateTime objects every time a tick event is received.
  late final Stream<DateTime> clockStream;

  ClockProvider() {
    clockStream = _timeTickEventChannel
        .receiveBroadcastStream()
        .map((event) => DateTime.fromMillisecondsSinceEpoch(event));
  }
}