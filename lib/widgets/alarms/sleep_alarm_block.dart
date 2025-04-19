import 'package:flutter/material.dart';
import 'package:nothing_clock/widgets/switch_button.dart';

/// Widget for displaying the fixed "Sleep Time" alarm.
/// This alarm is not managed like others and has a constant time.
class SleepAlarmBlock extends StatelessWidget {
  /// Whether the app is currently in dark mode.
  final bool isDarkMode;
  
  /// Time for the sleep alarm
  final DateTime sleepTime;
  
  /// Days the sleep alarm is active
  final List<String> sleepDays;
  
  /// Whether the sleep alarm is enabled
  final bool isSleepEnabled;
  
  /// Callback when the alarm is toggled
  final VoidCallback onToggle;

  const SleepAlarmBlock({
    super.key, 
    required this.isDarkMode,
    required this.sleepTime,
    required this.sleepDays,
    required this.isSleepEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Format time to display
    final formattedTime = "${sleepTime.hour.toString().padLeft(2, '0')}:${sleepTime.minute.toString().padLeft(2, '0')}";
    
    // Format days to display
    final formattedDays = sleepDays.join(", ");

    // Use a filled background in dark mode, or outlined in light mode.
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? theme.colorScheme.secondary : Colors.transparent,
        border: isDarkMode
            ? null
            : Border.all(color: theme.colorScheme.onSurface, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time and days description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedTime,
                style: theme.textTheme.titleLarge
                  ?.copyWith(color: theme.colorScheme.onSecondary, fontSize: 32)
              ),
              const SizedBox(height: 10),
              Text(
                formattedDays,
                style: TextStyle(color: theme.colorScheme.onSecondary)
              ),
            ],
          ),
          // Switch for sleep alarm
          SwitchButton(
            defaultValue: isSleepEnabled,
            onChanged: onToggle,
            inactiveTrackColor: Colors.transparent,
            activeTrackColor: Colors.transparent,
          ),
        ],
      ),
    );
  }
} 