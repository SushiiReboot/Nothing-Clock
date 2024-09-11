import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nothing_clock/services/location.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  Placemark? _currentAddress;

  Position? get currentPosition => _currentPosition;
  Placemark? get currentAddress => _currentAddress;

  LocationProvider() {
    initializeLocation();
  }

  Future<void> initializeLocation() async {
    Map<Position?, Placemark?> addressMap =
        await LocationService().getAddressFromLatLng(null);

    Placemark? address = addressMap.values.first;
    Position? position = addressMap.keys.first;

    _currentAddress = address;
    _currentPosition = position;
    notifyListeners();
  }
}
