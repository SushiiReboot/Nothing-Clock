import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nothing_clock/models/location_address.dart';
import 'package:nothing_clock/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A provider that retrieves and holds the user's current location and address,
/// notifying listeners when the location changes.
class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  Placemark? _currentAddress;

  Position? get currentPosition => _currentPosition;
  Placemark? get currentAddress => _currentAddress;

  LocationProvider() {
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final cached = await _loadCachedLocation();

    if(cached != null) {
      _currentPosition = cached.position;
      _currentAddress = cached.placemark;
      notifyListeners();

      return;
    }

    // If no cached data, fetch from the location service.
    _refreshLocation();
  }

  Future<void> _refreshLocation() async {
    try {
      final locationAddress = await LocationService().getAddressFromLatLng(null);
      _currentPosition = locationAddress.position;
      _currentAddress = locationAddress.placemark;
      notifyListeners();
      await _cacheLocation(locationAddress);
    } catch (e) {
      debugPrint("Error initializing location: $e");
    }
  }

  Future<void> _cacheLocation(LocationAddress location) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(location.toMap());
    await prefs.setString("cached_location", jsonString);
  }

  Future<LocationAddress?> _loadCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString("cached_location");
    if(jsonString == null) return null; //The user has not set a location yet

    try {
      Map<String, dynamic> json = jsonDecode(jsonString);
      return LocationAddress.fromMap(json);
    } catch (e) {
      debugPrint("Failed to load cached location: $e");
      return null;
    }
  }
}
