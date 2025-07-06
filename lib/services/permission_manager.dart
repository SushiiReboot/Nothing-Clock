import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  Future<void> requestMultiplePermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
    ].request();

    if (statuses[Permission.location]!.isGranted) {
      debugPrint('Location permission granted');
    } else {
      debugPrint('Location permission not granted');
    }
  }
}
