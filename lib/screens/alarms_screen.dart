import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nothing_clock/models/alarm.dart';
import 'package:nothing_clock/providers/theme_provider.dart';
import 'package:nothing_clock/services/alarms_service.dart';
import 'package:nothing_clock/widgets/switch_button.dart';
import 'package:provider/provider.dart';

class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({super.key});

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  List<Alarm> _alarms = [];

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  void _loadAlarms() async {
    _alarms = await AlarmsService().loadAlarms();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    double alarmBlockSize = (MediaQuery.of(context).size.width - 40 - 10) / 2;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("SLEEP TIME",
                        style: TextStyle(color: theme.colorScheme.onSurface)),
                    const SizedBox(
                      height: 15,
                    ),
                    _buildSleepAlarm(theme, themeProvider),
                    const SizedBox(
                      height: 35,
                    ),
                    Text("OTHER",
                        style: TextStyle(color: theme.colorScheme.onSurface)),
                    const SizedBox(
                      height: 15,
                    ),
                    SingleChildScrollView(
                      child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _alarms.length +
                              1, //Set to + 1 because we need to build the add alarm button
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (index == _alarms.length) {
                              //It goes outside the array bounds, but it builds the add alarm button {
                              return _buildAddAlarmButton(theme, alarmBlockSize,
                                  themeProvider, context);
                            }

                            return _buildAlarmBlock(
                                theme, _alarms[index], alarmBlockSize, context);
                          }),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  InkWell _buildAddAlarmButton(ThemeData theme, double alarmBlockSize,
      ThemeProvider themeProvider, BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return _buildModalBottomSheetUI(theme);
            });
      },
      child: Container(
        height: alarmBlockSize,
        width: alarmBlockSize,
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
                color: themeProvider.isDarkMode
                    ? Colors.white
                    : theme.colorScheme.tertiary,
                width: 0.5),
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add,
                color: themeProvider.isDarkMode
                    ? Colors.white
                    : theme.colorScheme.tertiary),
          ],
        ),
      ),
    );
  }

  Container _buildModalBottomSheetUI(ThemeData theme) {
    DateTime selectedTime = DateTime.now();
    Map<String, bool> selectedDays = {
      "MON": false,
      "TUE": false,
      "WED": false,
      "THU": false,
      "FRI": false,
      "SAT": false,
      "SUN": false
    };

    return Container(
      decoration: BoxDecoration(
          color: theme.colorScheme.tertiary,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 50,
              bottom: MediaQuery.of(context).viewInsets.bottom + 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("ADD NEW ALARM"),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      height: 150,
                      child: CupertinoTheme(
                        data: const CupertinoThemeData(
                            textTheme: CupertinoTextThemeData(
                                dateTimePickerTextStyle: TextStyle(
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.w100))),
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          initialDateTime: DateTime.now(),
                          onDateTimeChanged: (value) {
                            selectedTime = value;
                            debugPrint(
                                "Set time to $value. Selected days are: $selectedDays");
                          },
                        ),
                      ),
                    )),
              ),
              const SizedBox(
                height: 10,
              ),
              AlarmsDaysList(
                selectedDays: selectedDays,
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () async {
                  Alarm alarm = Alarm(time: selectedTime, days: selectedDays);
                  AlarmsService().saveAlarmData(alarm);

                  List<Alarm> updatedAlarms =
                      await AlarmsService().loadAlarms();
                  setState(() {
                    _alarms = updatedAlarms;
                  });
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                    backgroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text(
                  "SAVE ALARM",
                  style: TextStyle(
                      fontFamily: "Roboto", fontWeight: FontWeight.w500),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Container _buildAlarmBlock(ThemeData theme, Alarm alarm,
      double alarmBlockSize, BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    String time =
        "${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}";
    const days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];

    final activeDays = [
      for (var i = 0; i < days.length; i++)
        if (alarm.days[days[i]] ?? false) days[i]
    ].join(", ");

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
          color: theme.colorScheme.tertiary,
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style:
                    theme.textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                activeDays.isEmpty ? "EVERYDAY" : activeDays,
                style: TextStyle(color: theme.colorScheme.onTertiary),
              ),
            ],
          ),
          Positioned(
              top: alarmBlockSize - 80,
              left: 75,
              child: SwitchButton(
                defaultValue: alarm.isEnabled,
                onChanged: () {
                  alarm.isEnabled = !alarm.isEnabled;
                  if (alarm.isEnabled) {
                    AlarmsService().scheduleAlarmAt(alarm);
                  } else {
                    AlarmsService().cancelAlarm(alarm);
                  }
                  alarm.save();

                  debugPrint(
                      "Alarm with time: $time is now ${alarm.isEnabled}");
                },
                inactiveThumbColor: themeProvider.isDarkMode
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.surface,
                inactiveTrackColor: theme.colorScheme.tertiary,
                activeTrackColor: theme.colorScheme.tertiary,
                outlineColor: themeProvider.isDarkMode
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.surface,
              ))
        ]),
      ),
    );
  }

  Container _buildSleepAlarm(ThemeData theme, ThemeProvider themeProvider) {
    bool isDarkMode = themeProvider.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? theme.colorScheme.secondary : Colors.transparent,
        border: Border.all(
            width: isDarkMode ? 0 : 1,
            color:
                isDarkMode ? Colors.transparent : theme.colorScheme.onSurface),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "08:15",
                  style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSecondary, fontSize: 32),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "MON, TUE, WED",
                  style: TextStyle(color: theme.colorScheme.onSecondary),
                )
              ],
            ),
            const SwitchButton(
              inactiveTrackColor: Colors.transparent,
              activeTrackColor: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

class AlarmsDaysList extends StatefulWidget {
  const AlarmsDaysList({
    super.key,
    required this.selectedDays,
  });

  final Map<String, bool> selectedDays;

  @override
  State<AlarmsDaysList> createState() => _AlarmsDaysListState();
}

class _AlarmsDaysListState extends State<AlarmsDaysList> {
  String scheduledMessage = "Not scheduled";
  bool isScheduled = false;

  static const List<String> orderedDays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];


  void _changeScheduledMessage() {
    // Build a map of selected days using indices corresponding to orderedDays
    Map<int, bool> scheduledDays = {};
    for (int i = 0; i < orderedDays.length; i++) {
      if (widget.selectedDays[orderedDays[i]] ?? false) {
        scheduledDays[i] = true;
      }
    }
    debugPrint(scheduledDays.toString());

    if (!isScheduled) {
      scheduledMessage = "Not scheduled";
    } else if (scheduledDays.isEmpty) {
      scheduledMessage = "Today";
    } else {
      scheduledMessage = scheduledDays.keys.map((index) {
        return orderedDays[index];
      }).join(", ");
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15, left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(scheduledMessage,
                  style: theme.textTheme.labelLarge?.copyWith(
                      color: const Color.fromARGB(255, 163, 163, 163))),
              SwitchButton(
                onChanged: () {
                  setState(() {
                    isScheduled = !isScheduled;
                    _changeScheduledMessage();
                  });
                },
                inactiveTrackColor: Colors.transparent,
                activeTrackColor: Colors.transparent,
                outlineColor: Colors.white,
                inactiveThumbColor: Colors.white,
              )
            ],
          ),
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: orderedDays.map((day) {
              return AlarmDayBtn(
                dayInital: day.substring(0, 1),
                dayKey: day,
                selectedDays: widget.selectedDays,
                onPressed: () {
                  setState(() {
                    _changeScheduledMessage();
                  });
                },
                isEnabled: isScheduled,
                isSelected: widget.selectedDays[day] ?? false,  
              );
            }).toList())
      ],
    );
  }
}

class AlarmDayBtn extends StatefulWidget {
  const AlarmDayBtn({
    super.key,
    required this.dayInital,
    required this.dayKey,
    required this.selectedDays,
    this.onPressed,
    required this.isEnabled, required this.isSelected,
  });

  final String dayInital;
  final String dayKey;
  final Map<String, bool> selectedDays;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isSelected;

  @override
  State<AlarmDayBtn> createState() => _AlarmDayBtnState();
}

class _AlarmDayBtnState extends State<AlarmDayBtn> {
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected;
    debugPrint("Day ${widget.dayInital} is selected: $_isSelected");
  }

    @override
  void didUpdateWidget(covariant AlarmDayBtn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isEnabled != widget.isEnabled) {
      setState(() {
        if(!widget.isEnabled) {
          _isSelected = false;
          return;
        }

        _isSelected = widget.isSelected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    onSelect() {
      setState(() {
        _isSelected = !_isSelected;
        widget.selectedDays[widget.dayKey] = _isSelected;

        if (widget.onPressed != null) {
          widget.onPressed!();
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: Material(
          color: _isSelected && widget.isEnabled ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: _isSelected
                        ? Colors.transparent
                        : theme.colorScheme.secondary,
                    width: _isSelected ? 0 : 0.5)),
            child: InkWell(
                onTap: widget.isEnabled ? onSelect : null,
                radius: 50,
                borderRadius: BorderRadius.circular(50),
                child: Center(child: Text(widget.dayInital.toUpperCase()))),
          )),
    );
  }
}

class SwitchButtonBlock extends StatefulWidget {
  const SwitchButtonBlock({
    super.key,
  });

  @override
  State<SwitchButtonBlock> createState() => _SwitchButtonBlockState();
}

class _SwitchButtonBlockState extends State<SwitchButtonBlock> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, left: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Switch(
              value: _isActive,
              inactiveTrackColor: Colors.transparent,
              trackOutlineWidth: WidgetStateProperty.resolveWith<double?>(
                  (Set<WidgetState> states) {
                return 0.8; // Use the default width.
              }),
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              })
        ],
      ),
    );
  }
}
