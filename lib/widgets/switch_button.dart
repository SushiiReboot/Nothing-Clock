import 'package:flutter/material.dart';

class SwitchButton extends StatefulWidget {
  const SwitchButton({
    super.key,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.activeColor,
    this.inactiveThumbColor,
    this.onChanged,
    this.defaultValue,
    this.outlineColor,
  });

  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final Color? activeColor;
  final Color? inactiveThumbColor;
  final bool? defaultValue;
  final Color? outlineColor;

  final VoidCallback? onChanged;

  @override
  State<SwitchButton> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton> {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.defaultValue ?? false;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Switch(
      value: _isActive,
      onChanged: (value) {
        setState(() {
          _isActive = value;
          widget.onChanged?.call();
        });
      },
      activeTrackColor: widget.activeTrackColor ?? theme.colorScheme.secondary,
      inactiveTrackColor: widget.inactiveTrackColor ??
          theme.colorScheme.secondary.withOpacity(0.5),
      activeColor: widget.activeColor ?? theme.colorScheme.primary,
      inactiveThumbColor:
          widget.inactiveThumbColor ?? theme.colorScheme.onSecondary,
      trackOutlineColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        return widget.outlineColor ?? Colors.black; // Use the default color.
      }),
      trackOutlineWidth:
          WidgetStateProperty.resolveWith<double?>((Set<WidgetState> states) {
        return 0.8; // Use the default width.
      }),
    );
  }
}
