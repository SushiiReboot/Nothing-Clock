import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nothing_clock/models/alarm.dart';
import 'package:nothing_clock/providers/clock_provider.dart';
import 'package:nothing_clock/providers/page_provider.dart';
import 'package:nothing_clock/providers/stopwatch_provider.dart';
import 'package:nothing_clock/providers/theme_provider.dart';
import 'package:nothing_clock/providers/timer_provider.dart';
import 'package:nothing_clock/providers/worldclocks_provider.dart';
import 'package:nothing_clock/screens/router.dart' as RouterPage;
import 'package:nothing_clock/services/notification_service.dart';
import 'package:nothing_clock/services/time_country.dart';
import 'package:nothing_clock/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:nothing_clock/services/alarms_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDisplayMode.setHighRefreshRate();

  if (!Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
  }

  tz.initializeTimeZones();
  await TimeCountry.init();

  await Hive.initFlutter();
  Hive.registerAdapter(AlarmAdapter());

  // Register a named port for alarm callbacks to communicate with the main isolate
  IsolateNameServer.registerPortWithName(
    ReceivePort().sendPort,
    'alarmPort',
  );
  
  // Register a named port for timer callbacks
  IsolateNameServer.registerPortWithName(
    ReceivePort().sendPort,
    'timer_port',
  );
  
  // Listen for alarm messages
  ReceivePort receivePort = ReceivePort();
  IsolateNameServer.registerPortWithName(
    receivePort.sendPort,
    'alarmPort',
  );
  
  // Listen for timer messages
  ReceivePort timerReceivePort = ReceivePort();
  IsolateNameServer.registerPortWithName(
    timerReceivePort.sendPort,
    'timer_port',
  );
  
  timerReceivePort.listen((message) async {
    debugPrint("Timer message received: $message");
    // Background timer events will be handled by the TimerProvider
  });
  
  receivePort.listen((message) async {
    if (message == 'showNotification') {
      await NotificationService.showFullScreenNotification(
        id: 0, 
        title: 'Alarm', 
        body: 'Your alarm is ringing!',
      );
      debugPrint("Notification received!");
    }
  });
  
  // Initialize alarm manager and notification service
  await AndroidAlarmManager.initialize();
  await NotificationService.initialize();
  
  // Request necessary permissions for exact alarms
  final alarmService = AlarmsService();
  final canScheduleExactAlarms = await alarmService.canScheduleExactAlarms();
  if (!canScheduleExactAlarms) {
    // Open settings to allow user to grant permission
    await AlarmsService.openExactAlarmSettings();
  }

  final themeProvider = ThemeProvider();
  await themeProvider.loadThemeFromPreferences();

  runApp(
    ChangeNotifierProvider(
      create: (context) => themeProvider,
      child: const NothingClock(),
    ),
  );
}

class NothingClock extends StatelessWidget {
  const NothingClock({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ClockProvider()),
        ChangeNotifierProvider(create: (context) => PageProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => TimerProvider()),
        ChangeNotifierProvider(create: (context) => StopwatchProvider()),
        ChangeNotifierProvider(
            create: (context) => WorldClocksProvider(context))
      ],
      child: Consumer<ThemeProvider>(builder: (context, value, child) {
        return MaterialApp(
          title: 'Nothing Clock',
          debugShowCheckedModeBanner: false,
          darkTheme: AppTheme.dark,
          theme: AppTheme.light,
          themeMode: value.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const RouterPage.Router(),
        );
      },)
    );
  }
}
