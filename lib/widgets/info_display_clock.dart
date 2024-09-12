import 'package:flutter/material.dart';

class InfoDisplayClock extends StatelessWidget {
  const InfoDisplayClock({
    super.key,
    required this.color,
    required this.text,
    this.icon,
    required this.foregroundColor,
    this.onTap,
    this.outlineColor,
  });

  final VoidCallback? onTap;
  final Color color;
  final Color? outlineColor;
  final Color foregroundColor;
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: outlineColor ?? Colors.transparent,
              width: outlineColor != null ? 1 : 0,
            )),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(50),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(50),
            child: SizedBox(
              height: 80,
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
          ),
        ),
      ),
    );
  }
}
