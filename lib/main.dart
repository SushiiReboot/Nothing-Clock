import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nothing_clock/providers/location_provider.dart';
import 'package:nothing_clock/screens/router.dart' as RouterPage;
import 'package:nothing_clock/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDisplayMode.setHighRefreshRate();

  tz.initializeTimeZones();

  // Get the timezone location for New York
  final location = tz.getLocation('America/New_York');

  // Get the current time in the specified location
  final currentTime = tz.TZDateTime.now(location);

  // Get the timezone offset in hours (duration from UTC)
  final utcOffset = currentTime.timeZoneOffset.inHours;

  // Print the UTC offset (e.g., UTC -5, UTC +1)
  print('Current time in America/New_York: $currentTime');
  print('UTC offset: UTC ${utcOffset >= 0 ? '+' : ''}$utcOffset');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => LocationProvider(),
      child: MaterialApp(
        title: 'Nothing Clock',
        debugShowCheckedModeBanner: false,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const RouterPage.Router(),
      ),
    );
  }
}
