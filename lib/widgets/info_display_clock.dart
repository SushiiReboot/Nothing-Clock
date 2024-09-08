import 'package:flutter/material.dart';

class InfoDisplayClock extends StatelessWidget {
  const InfoDisplayClock({
    super.key,
    required this.color,
    required this.text,
    this.icon,
    required this.foregroundColor,
  });

  final Color color;
  final Color foregroundColor;
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 80,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(50)),
        child: Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text.toUpperCase(),
              style: TextStyle(color: foregroundColor),
            ),
            if (icon != null) ...[
              const SizedBox(
                width: 15,
              ),
              Icon(
                icon,
                color: foregroundColor,
                size: 15,
              )
            ]
          ],
        )),
      ),
    );
  }
}
