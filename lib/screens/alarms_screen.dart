import 'package:flutter/material.dart';
import 'package:nothing_clock/providers/theme_provider.dart';
import 'package:nothing_clock/widgets/switch_button.dart';
import 'package:provider/provider.dart';

class AlarmsScreen extends StatelessWidget {
  const AlarmsScreen({super.key});

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
                    SizedBox(
                        height: 200,
                        child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 2,
                            itemBuilder: (context, index) {
                              return _buildAlarmBlock(
                                  theme, index, alarmBlockSize, context);
                            })),
                    InkWell(
                      onTap: () {
                        showModalBottomSheet<void>(
                            context: context,
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 22),
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
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _buildModalBottomSheetUI(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
          color: theme.colorScheme.tertiary,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      height: 500,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("ALARMS"),
            const SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: theme.colorScheme.secondary, width: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "18:26",
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontSize: 40, letterSpacing: 5),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const AlarmsDaysList()
          ],
        ),
      ),
    );
  }

  Container _buildAlarmBlock(
      ThemeData theme, int index, double alarmBlockSize, BuildContext context) {
    List<String> _testAlarmClocks = ["08:15", "09:15"];
    List<String> _testAlarmDays = ["MON, TUE", "MON, TUE, WED"];

    final themeProvider = Provider.of<ThemeProvider>(context);

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
                _testAlarmClocks[index],
                style:
                    theme.textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                _testAlarmDays[index],
                style: TextStyle(color: theme.colorScheme.onTertiary),
              ),
            ],
          ),
          Positioned(
              top: alarmBlockSize - 80,
              left: 75,
              child: SwitchButton(
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

class AlarmsDaysList extends StatelessWidget {
  const AlarmsDaysList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15, left: 10),
          child: Text("DAYS",
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: const Color.fromARGB(255, 163, 163, 163))),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AlarmDayBtn(
              dayInital: "M",
            ),
            AlarmDayBtn(
              dayInital: "T",
            ),
            AlarmDayBtn(
              dayInital: "W",
            ),
            AlarmDayBtn(
              dayInital: "T",
            ),
            AlarmDayBtn(
              dayInital: "F",
            ),
            AlarmDayBtn(
              dayInital: "S",
            ),
            AlarmDayBtn(
              dayInital: "S",
            ),
          ],
        )
      ],
    );
  }
}

class AlarmDayBtn extends StatefulWidget {
  const AlarmDayBtn({
    super.key,
    required this.dayInital,
  });

  final String dayInital;

  @override
  State<AlarmDayBtn> createState() => _AlarmDayBtnState();
}

class _AlarmDayBtnState extends State<AlarmDayBtn> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    _onSelect() {
      setState(() {
        _isSelected = !_isSelected;
      });
    }

    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: Material(
          color: _isSelected ? theme.colorScheme.primary : Colors.transparent,
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
                onTap: _onSelect,
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
