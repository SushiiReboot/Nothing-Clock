import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nothing_clock/models/alarm.dart';
import 'package:nothing_clock/widgets/alarms/day_selector.dart';

/// Bottom sheet that allows the user to pick a time and days for a new alarm.
class AlarmFormBottomSheet extends StatefulWidget {
  /// Callback when a new alarm is saved
  final Function(Alarm) onSave;
  
  const AlarmFormBottomSheet({
    super.key,
    required this.onSave,
  });

  @override
  State<AlarmFormBottomSheet> createState() => _AlarmFormBottomSheetState();
}

/// State for [AlarmFormBottomSheet], maintains form selections.
class _AlarmFormBottomSheetState extends State<AlarmFormBottomSheet> {
  /// The currently selected time for the new alarm
  DateTime _selectedTime = DateTime.now();
  
  /// Map of days and their selection state
  Map<String, bool> _selectedDays = {
    "MON": false,
    "TUE": false,
    "WED": false,
    "THU": false,
    "FRI": false,
    "SAT": false,
    "SUN": false
  };
  
  /// Whether the alarm is scheduled for specific days
  bool _isScheduled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
          color: theme.colorScheme.tertiary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      child: Padding(
        padding: EdgeInsets.only(
            left: 10,
            right: 10,
            top: 50,
            bottom: MediaQuery.of(context).viewInsets.bottom + 40),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text("ADD NEW ALARM", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              // Time picker section
              _buildTimePicker(),
              const SizedBox(height: 10),
              
              // Days selector widget
              AlarmsDaysList(
                selectedDays: _selectedDays,
                isScheduled: _isScheduled,
                onScheduleChanged: (val) {
                  setState(() {
                    _isScheduled = val;
                  });
                },
              ),
              const SizedBox(height: 20),
              
              // Save button
              _buildSaveButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the time picker widget with Cupertino style
  Widget _buildTimePicker() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          height: 150,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            initialDateTime: _selectedTime,
            onDateTimeChanged: (value) {
              setState(() {
                _selectedTime = value;
              });
            },
          ),
        ),
      ),
    );
  }

  /// Builds the save button with consistent styling
  Widget _buildSaveButton(ThemeData theme) {
    return TextButton(
      onPressed: _onSavePressed,
      style: TextButton.styleFrom(
        backgroundColor: theme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        "SAVE ALARM",
        style: TextStyle(fontFamily: "Roboto", fontWeight: FontWeight.w500),
      ),
    );
  }

  /// Handles saving the new alarm using the provided callback.
  void _onSavePressed() {
    // Create a new alarm with the selected settings
    final newAlarm = Alarm(time: _selectedTime, days: _selectedDays);
    
    // Call the save callback provided by parent
    widget.onSave(newAlarm);
    
    // Close the bottom sheet
    Navigator.pop(context);
  }
} 