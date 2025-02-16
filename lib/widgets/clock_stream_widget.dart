import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClockStreamWidget extends StatefulWidget {
  const ClockStreamWidget({super.key});

  @override
  State<ClockStreamWidget> createState() => _ClockStreamWidgetState();
}

class _ClockStreamWidgetState extends State<ClockStreamWidget> {
  static const _clockEventChannel = EventChannel("clockEventChannel");
  late Stream<DateTime> _clockStream;

  @override
  void initState() {
    super.initState();
    _clockStream = _clockEventChannel
        .receiveBroadcastStream()
        .map((event) => DateTime.fromMillisecondsSinceEpoch(event));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(stream: _clockStream, builder:(context, snapshot) {
      if(!snapshot.hasData) return const CircularProgressIndicator();
      final time = snapshot.data!;  
      final formattedDate = "${time.hour.toString().padLeft(2, "0")}:${time.minute.toString().padLeft(2, "0")}";

      return Text(formattedDate, style: const TextStyle(fontSize: 60, fontFamily: "NDot"),);
    }, initialData: DateTime.now(),);
  }
}
