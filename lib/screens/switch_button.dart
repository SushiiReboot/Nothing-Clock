import 'package:flutter/material.dart';

class SwitchButton extends StatefulWidget {
  const SwitchButton({
    super.key,
  });

  @override
  State<SwitchButton> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Switch(
      value: _isActive,
      onChanged: (value) {
        setState(() {
          _isActive = value;
        });
      },
      activeTrackColor: theme.colorScheme.secondary,
      inactiveTrackColor: theme.colorScheme.secondary.withOpacity(0.5),
      activeColor: theme.colorScheme.primary,
      inactiveThumbColor: theme.colorScheme.surface,
      trackOutlineColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        return Colors.black; // Use the default color.
      }),
      trackOutlineWidth:
          WidgetStateProperty.resolveWith<double?>((Set<WidgetState> states) {
        return 0.8; // Use the default width.
      }),
    );
  }
}
