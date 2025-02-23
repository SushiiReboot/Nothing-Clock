import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// A service class to handle notification-related functionalities, including
/// initializing the notification plugin, showing full-screen notifications,
/// and checking/requesting notification permissions.
class NotificationService {

  /// A singleton instance of the FlutterLocalNotificationsPlugin used for
  /// managing local notifications.
  static final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Initializes the local notifications plugin.
  ///
  /// This method sets up the plugin with the required Android initialization
  /// settings (using the app icon specified in `@mipmap/ic_launcher`) and a
  /// callback for when a notification response is received. If the payload is
  /// "alarm_triggered", it prints a debug message.
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // your app icon

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (details) {
      final payload = details.payload;
      if(payload == "alarm_triggered") {
        debugPrint("Alarm triggered!");
      }
    },);
  }

  /// Shows a full-screen notification.
  ///
  /// The notification is configured with high priority and importance, as well
  /// as a full-screen intent. This is typically used to alert the user (e.g.,
  /// when an alarm triggers) even when the device is locked or the app is in the
  /// background.
  ///
  /// - Parameters:
  ///   - id: A unique identifier for the notification.
  ///   - title: The title of the notification.
  ///   - body: The body content of the notification.
  static Future<void> showFullScreenNotification({required int id, required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'full_screen_channel', 'Full Screen Notifications', channelDescription: 'Channel for full screen notifications',
        priority: Priority.high,
        importance: Importance.max,
        fullScreenIntent: true,
        ticker: "ticker",
        styleInformation: BigTextStyleInformation(''));
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: "alarm_triggered");
  }

  /// Checks and requests notification permission from the user.
  ///
  /// This method uses the `permission_handler` package to check whether the
  /// notification permission is granted. If not, it requests the permission.
  /// Debug messages are printed if the permission is denied or permanently denied.
  Future<void> checkAndRequestNotificationPermission() async {
    final status = await Permission.notification.status;

    if(status.isGranted) {
      return;
    }
    
    final result = await Permission.notification.request();
    if(result.isGranted) {
      return;
    }

    if(result.isDenied) {
      debugPrint("Notification permission is denied");
    } else if(result.isPermanentlyDenied) {
      debugPrint("Notification permission is permanently denied");
    }
  }
}