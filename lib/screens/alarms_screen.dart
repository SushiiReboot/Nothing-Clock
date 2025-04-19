import 'package:flutter/material.dart';
import 'package:nothing_clock/providers/theme_provider.dart';
import 'package:nothing_clock/view_models/alarms_view_model.dart';
import 'package:nothing_clock/widgets/alarms/alarm_grid.dart';
import 'package:nothing_clock/widgets/alarms/sleep_alarm_block.dart';
import 'package:provider/provider.dart';

/// The main screen for displaying and managing alarms.
/// Shows a fixed "Sleep Time" alarm and a grid of other alarms.
class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({super.key});

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

/// State class for [AlarmsScreen].
/// Handles loading alarms from storage and updating UI.
class _AlarmsScreenState extends State<AlarmsScreen> {
  /// View model that manages business logic for the alarms
  late AlarmsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    
    // Initialize view model
    _viewModel = AlarmsViewModel();
    
    // Load alarms data when screen initializes
    _loadAlarms();
  }

  /// Loads alarms asynchronously via the view model.
  Future<void> _loadAlarms() async {
    await _viewModel.loadAlarms();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Calculate block size dynamically based on screen width and padding.
    // This ensures proper responsive layout across different screen sizes.
    final blockSize = (MediaQuery.of(context).size.width - 40 - 10) / 2;

    // Wrap the UI in a ListenableBuilder to respond to view model changes
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sleep Time section header
                    _buildSectionHeader("SLEEP TIME", theme),
                    const SizedBox(height: 15),
                    
                    // Custom widget for Sleep Time alarm
                    SleepAlarmBlock(
                      isDarkMode: themeProvider.isDarkMode,
                      sleepTime: _viewModel.sleepTime,
                      sleepDays: _viewModel.sleepDays,
                      isSleepEnabled: _viewModel.isSleepEnabled,
                      onToggle: _viewModel.toggleSleepEnabled,
                    ),
                    const SizedBox(height: 35),
                    
                    // Other alarms section header
                    _buildSectionHeader("OTHER", theme),
                    const SizedBox(height: 15),
                    
                    // Grid of alarms with add button
                    AlarmGrid(
                      alarms: _viewModel.alarms,
                      blockSize: blockSize,
                      onToggleAlarm: _viewModel.toggleAlarmState,
                      onAddAlarm: (alarm) => _viewModel.addAlarm(alarm),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Creates a consistently styled section header
  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
      ),
    );
  }
}
