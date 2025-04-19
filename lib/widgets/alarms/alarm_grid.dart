import 'package:flutter/material.dart';
import 'package:nothing_clock/models/alarm.dart';
import 'package:nothing_clock/providers/theme_provider.dart';
import 'package:nothing_clock/widgets/alarms/alarm_form_bottom_sheet.dart';
import 'package:nothing_clock/widgets/switch_button.dart';
import 'package:provider/provider.dart';

/// Grid widget that displays existing alarms and a button to add a new one.
class AlarmGrid extends StatelessWidget {
  /// List of alarms to render in the grid.
  final List<Alarm> alarms;

  /// The width/height of each grid cell.
  final double blockSize;
  
  /// Callback when an alarm is toggled
  final Function(Alarm) onToggleAlarm;
  
  /// Callback when a new alarm is added
  final Function(Alarm) onAddAlarm;

  const AlarmGrid({
    super.key, 
    required this.alarms, 
    required this.blockSize,
    required this.onToggleAlarm,
    required this.onAddAlarm,
  });

  @override
  Widget build(BuildContext context) {
    // Using GridView.builder for dynamic items + add button.
    // This is efficient since it only builds visible items.
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: alarms.length + 1, // +1 for the add button
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemBuilder: (ctx, idx) {
        // Check if we're building the last item (add button)
        if (idx == alarms.length) {
          // Render the add button as the last item.
          return AddAlarmButton(
            blockSize: blockSize,
            onAddAlarm: onAddAlarm,
          );
        }
        // Render a single alarm block.
        return AlarmBlock(
          alarm: alarms[idx], 
          blockSize: blockSize,
          onToggle: () => onToggleAlarm(alarms[idx]),
        );
      },
    );
  }
}

/// Button that opens the bottom sheet to create a new alarm.
class AddAlarmButton extends StatelessWidget {
  /// Size of the button block
  final double blockSize;
  
  /// Callback when a new alarm is added
  final Function(Alarm) onAddAlarm;

  const AddAlarmButton({
    super.key, 
    required this.blockSize,
    required this.onAddAlarm,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        // Show modal bottom sheet for adding a new alarm.
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true, // Allow sheet to expand based on content
          builder: (_) => AlarmFormBottomSheet(
            onSave: onAddAlarm,
          ),
        );
      },
      child: Container(
        width: blockSize,
        height: blockSize,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
              color: themeProvider.isDarkMode
                  ? Colors.white
                  : theme.colorScheme.tertiary,
              width: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.add,
          color: themeProvider.isDarkMode
              ? Colors.white
              : theme.colorScheme.tertiary
        ),
      ),
    );
  }
}

/// Widget for a single alarm block, showing time, active days, and enable switch.
class AlarmBlock extends StatelessWidget {
  /// The alarm data to display
  final Alarm alarm;
  
  /// Size of the alarm block
  final double blockSize;
  
  /// Callback when the alarm is toggled
  final VoidCallback onToggle;

  const AlarmBlock({
    super.key, 
    required this.alarm, 
    required this.blockSize,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    // Format HH:MM string, ensuring leading zeros.
    final timeString = "${alarm.time.hour.toString().padLeft(2, '0')}:"
        "${alarm.time.minute.toString().padLeft(2, '0')}";

    // Compute display of selected days or 'EVERYDAY'.
    const daysOrder = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
    final activeDays = daysOrder.where((d) => alarm.days[d] ?? false).toList();
    final daysText = activeDays.isEmpty ? "EVERYDAY" : activeDays.join(", ");

    return Container(
      width: blockSize,
      height: blockSize,
      decoration: BoxDecoration(
          color: theme.colorScheme.tertiary,
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Stack(children: [
          // Top-left: Time and day labels
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(timeString,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(color: Colors.white)),
              const SizedBox(height: 10),
              Text(daysText, style: TextStyle(color: theme.colorScheme.onTertiary)),
            ],
          ),
          // Bottom switch to enable/disable alarm
          Positioned(
            top: blockSize - 80,
            left: blockSize / 2 - 16,
            child: SwitchButton(
              defaultValue: alarm.isEnabled,
              onChanged: onToggle,
              inactiveThumbColor: themeProvider.isDarkMode
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.surface,
              inactiveTrackColor: theme.colorScheme.tertiary,
              activeTrackColor: theme.colorScheme.tertiary,
              outlineColor: themeProvider.isDarkMode
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.surface,
            ),
          ),
        ]),
      ),
    );
  }
} 