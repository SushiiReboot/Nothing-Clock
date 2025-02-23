import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  Future<void> requestMultiplePermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
      Permission.storage,
    ].request();

    // You can check the status of each permission like this:
    if (statuses[Permission.location]!.isGranted) {
      debugPrint('Location permission granted');
    } else {
      debugPrint('Location permission not granted');
    }

    if (statuses[Permission.camera]!.isGranted) {
      debugPrint('Camera permission granted');
    } else {
      debugPrint('Camera permission not granted');
    }

    if (statuses[Permission.storage]!.isGranted) {
      debugPrint('Storage permission granted');
    } else {
      debugPrint('Storage permission not granted');
    }
  }
}
