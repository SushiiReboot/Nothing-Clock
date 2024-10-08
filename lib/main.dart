import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:nothing_clock/providers/location_provider.dart';
import 'package:nothing_clock/providers/page_provider.dart';
import 'package:nothing_clock/providers/theme_provider.dart';
import 'package:nothing_clock/providers/timer_provider.dart';
import 'package:nothing_clock/providers/worldclocks_provider.dart';
import 'package:nothing_clock/screens/router.dart' as RouterPage;
import 'package:nothing_clock/services/time_country.dart';
import 'package:nothing_clock/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDisplayMode.setHighRefreshRate();

  tz.initializeTimeZones();
  await TimeCountry.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TimerProvider()),
        ChangeNotifierProvider(create: (context) => LocationProvider()),
        ChangeNotifierProvider(create: (context) => PageProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProxyProvider<TimerProvider, WorldClocksProvider>(
          create: (context) =>
              WorldClocksProvider(context.read<TimerProvider>()),
          update: (context, timerProvider, worldClocksProvider) =>
              worldClocksProvider!..updateWorldClocks(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) => MaterialApp(
          title: 'Nothing Clock',
          debugShowCheckedModeBanner: false,
          darkTheme: AppTheme.dark,
          theme: AppTheme.light,
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const RouterPage.Router(),
        ),
      ),
    );
  }
}
