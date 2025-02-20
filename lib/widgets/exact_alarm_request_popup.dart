import 'package:flutter/material.dart';

class ExactAlarmRequestPopup extends StatefulWidget {
  const ExactAlarmRequestPopup({super.key});

  @override
  State<ExactAlarmRequestPopup> createState() => _ExactAlarmRequestPopupState();
}

class _ExactAlarmRequestPopupState extends State<ExactAlarmRequestPopup> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}