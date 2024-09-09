import 'package:flutter/material.dart';

class AlarmsScreen extends StatelessWidget {
  const AlarmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SLEEP TIME",
                      style:
                          TextStyle(color: Color.fromARGB(255, 128, 128, 128))),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(45.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                "08:15",
                                style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.black, fontSize: 40),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                "MON, TUE, WED",
                                style: TextStyle(color: Colors.black),
                              )
                            ],
                          ),
                          Switch(value: true, onChanged: (value) {}),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
