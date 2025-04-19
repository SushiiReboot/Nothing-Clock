import 'package:flutter/material.dart';

class StopwatchBtnController extends StatefulWidget {
  const StopwatchBtnController({
    super.key,
    required this.isFilled,
    required this.filledColor,
    required this.borderColor,
    required this.iconColor,
    required this.icon,
    this.onTap,
  });

  final bool isFilled;
  final Color? filledColor;
  final Color borderColor;
  final Color? iconColor;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  State<StopwatchBtnController> createState() => _StopwatchBtnControllerState();
}

class _StopwatchBtnControllerState extends State<StopwatchBtnController> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
            color: widget.isFilled ? widget.filledColor : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: widget.borderColor, width: 1)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Icon(
            widget.icon,
            color: !widget.isFilled ? widget.borderColor : widget.iconColor,
          ),
        ),
      ),
    );
  }
}
