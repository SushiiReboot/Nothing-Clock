import 'package:flutter/material.dart';
import 'package:nothing_clock/widgets/switch_button.dart';

/// A list widget that shows the scheduled toggle and day buttons for an alarm.
class AlarmsDaysList extends StatefulWidget {
  /// Map of days and their selection state
  final Map<String, bool> selectedDays;
  
  /// Whether scheduling is enabled
  final bool isScheduled;
  
  /// Callback when schedule toggle changes
  final ValueChanged<bool> onScheduleChanged;

  const AlarmsDaysList({
    super.key, 
    required this.selectedDays,
    required this.isScheduled,
    required this.onScheduleChanged,
  });

  @override
  State<AlarmsDaysList> createState() => _AlarmsDaysListState();
}

/// State for [AlarmsDaysList], manages toggle and scheduled message.
class _AlarmsDaysListState extends State<AlarmsDaysList> {
  /// Day names in order for display and selection
  static const _orderedDays = ["MON","TUE","WED","THU","FRI","SAT","SUN"];

  /// Computed message based on selected days
  String get _scheduledMessage {
    if (!widget.isScheduled) {
      return "Not scheduled";
    }
    
    final selected = <String>[];
    for (var day in _orderedDays) {
      if (widget.selectedDays[day] == true) {
        selected.add(day);
      }
    }
    return selected.isEmpty ? "Today" : selected.join(", ");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: scheduled message and toggle switch
        Padding(
          padding: const EdgeInsets.only(bottom: 15, left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Display schedule message (days or "Not scheduled")
              Text(_scheduledMessage,
                  style: theme.textTheme.labelLarge?.copyWith(color: const Color(0xFFA3A3A3))),
              
              // Toggle switch for enabling day selection
              SwitchButton(
                defaultValue: widget.isScheduled,
                onChanged: () {
                  widget.onScheduleChanged(!widget.isScheduled);
                },
                inactiveTrackColor: Colors.transparent,
                activeTrackColor: Colors.transparent,
                outlineColor: Colors.white,
                inactiveThumbColor: Colors.white,
              )
            ],
          ),
        ),
        // Row of day buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _orderedDays.map((day) {
            return AlarmDayBtn(
              dayInital: day.substring(0, 1),
              dayKey: day,
              selectedDays: widget.selectedDays,
              isEnabled: widget.isScheduled,
              isSelected: widget.selectedDays[day] ?? false,
              onPressed: () {
                // Trigger rebuild to update schedule message
                setState(() {});
              },
            );
          }).toList(),
        )
      ],
    );
  }
}

/// Button representing a single day in the alarm day selector.
class AlarmDayBtn extends StatefulWidget {
  /// First letter of the day to display
  final String dayInital;
  
  /// Full day name (key in the days map)
  final String dayKey;
  
  /// Reference to parent's days map
  final Map<String, bool> selectedDays;
  
  /// Whether day selection is enabled
  final bool isEnabled;
  
  /// Whether this day is selected
  final bool isSelected;
  
  /// Callback when selection changes
  final VoidCallback? onPressed;

  const AlarmDayBtn({
    super.key,
    required this.dayInital,
    required this.dayKey,
    required this.selectedDays,
    required this.isEnabled,
    required this.isSelected,
    this.onPressed,
  });

  @override
  State<AlarmDayBtn> createState() => _AlarmDayBtnState();
}

/// State for [AlarmDayBtn], manages visual selection and toggling.
class _AlarmDayBtnState extends State<AlarmDayBtn> {
  /// Local selection state
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.isSelected;
  }

  @override
  void didUpdateWidget(covariant AlarmDayBtn oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset selection when disabling the scheduler
    if (!widget.isEnabled) {
      setState(() => _selected = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Visual appearance changes based on selection state
    final bool isActive = _selected && widget.isEnabled;
    final Color backgroundColor = isActive 
        ? theme.colorScheme.primary 
        : Colors.transparent;
    final Color borderColor = _selected 
        ? Colors.transparent 
        : theme.colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: 0.5,
            ),
          ),
          child: InkWell(
            onTap: widget.isEnabled ? _toggle : null,
            borderRadius: BorderRadius.circular(50),
            child: Center(child: Text(widget.dayInital)),
          ),
        ),
      ),
    );
  }

  /// Toggles selection state and updates parent map.
  void _toggle() {
    setState(() {
      // Toggle local selection state
      _selected = !_selected;
      
      // Update parent's map with new selection
      widget.selectedDays[widget.dayKey] = _selected;
    });
    
    // Notify parent of selection change
    widget.onPressed?.call();
  }
} 