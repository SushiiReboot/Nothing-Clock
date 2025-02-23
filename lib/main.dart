import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nothing_clock/models/alarm.dart';
import 'package:nothing_clock/providers/clock_provider.dart';
import 'package:nothing_clock/providers/page_provider.dart';
import 'package:nothing_clock/providers/theme_provider.dart';
import 'package:nothing_clock/providers/worldclocks_provider.dart';
import 'package:nothing_clock/screens/router.dart' as RouterPage;
import 'package:nothing_clock/services/notification_service.dart';
import 'package:nothing_clock/services/time_country.dart';
import 'package:nothing_clock/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDisplayMode.setHighRefreshRate();

  tz.initializeTimeZones();
  await TimeCountry.init();

  await Hive.initFlutter();
  Hive.registerAdapter(AlarmAdapter());

    final ReceivePort receivePort = ReceivePort();
  IsolateNameServer.registerPortWithName(receivePort.sendPort, "alarmPort");

  receivePort.listen((message) async {
    if(message == "showNotification") {
      await NotificationService.showFullScreenNotification(
          id: 0,
          title: "Alarm",
          body: "Alarm triggered!");

      debugPrint("Notificaiton received!");
    }
  }); 

  AndroidAlarmManager.initialize();
  await NotificationService.initialize();

  final theme = await ThemeProvider().loadThemeFromPreferences();
  final themeMode = theme ? AppTheme.dark : AppTheme.light;
  runApp(NothingClock(theme: themeMode));
}

class NothingClock extends StatelessWidget {
  const NothingClock({super.key, required this.theme});

  final ThemeData theme;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ClockProvider()),
        ChangeNotifierProvider(create: (context) => PageProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(
            create: (context) => WorldClocksProvider(context))
      ],
      child: MaterialApp(
        title: 'Nothing Clock',
        debugShowCheckedModeBanner: false,
        darkTheme: AppTheme.dark,
        theme: AppTheme.light,
        themeMode: theme == AppTheme.dark ? ThemeMode.dark : ThemeMode.light,
        home: const RouterPage.Router(),
      ),
    );
  }
}
