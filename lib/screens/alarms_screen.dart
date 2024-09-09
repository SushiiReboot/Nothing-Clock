import 'package:flutter/material.dart';
import 'package:nothing_clock/screens/switch_button.dart';

class AlarmsScreen extends StatelessWidget {
  const AlarmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

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
                    const Text("SLEEP TIME",
                        style: TextStyle(
                            color: Color.fromARGB(255, 128, 128, 128))),
                    const SizedBox(
                      height: 20,
                    ),
                    _buildSleepAlarm(theme),
                    const SizedBox(
                      height: 20,
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
                              return _buildAlarmBlock(theme);
                            })),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                                color: theme.colorScheme.secondary, width: 0.5),
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 22),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 20),
                            Text(
                              "ADD MORE",
                              style: TextStyle(letterSpacing: 1.5),
                            ),
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

  Container _buildAlarmBlock(ThemeData theme) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
          color: theme.colorScheme.tertiary,
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 25.0, left: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "08:15",
                  style:
                      theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text("MON, TUE")
              ],
            ),
          ),
          const SwitchButtonBlock()
        ],
      ),
    );
  }

  Container _buildSleepAlarm(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
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
                  style: theme.textTheme.titleLarge
                      ?.copyWith(color: Colors.black, fontSize: 32),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "MON, TUE, WED",
                  style: TextStyle(color: Colors.black),
                )
              ],
            ),
            const SwitchButton(),
          ],
        ),
      ),
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
