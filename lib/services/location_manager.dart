import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nothing_clock/models/user_position.dart';

/// A service class that handles retrieving and saving user location data,
/// including determining the current position and converting coordinates to an address.
class LocationManager {
  static final LocationManager _instance = LocationManager._internal();

  /// The current user position, including latitude, longitude, and optionally a placemark.
  UserPosition? _currentPosition;

  /// Public getter for the current user position.
  UserPosition? get currentPosition => _currentPosition;

  late final Future<void> initialization;

  /// Creates a [LocationManager] instance and initializes the user location.
  ///
  /// The constructor automatically calls [_initializeLocation] to load any cached location
  /// data or refresh it if necessary.
  LocationManager._internal() {
    initialization = _initializeLocation();
  }

  factory LocationManager() {
    return _instance;
  }

  /// Converts the given [position] into a [UserPosition] by fetching a placemark
  /// corresponding to the latitude and longitude.
  ///
  /// If [position] is null, the method will determine the user's position.
  ///
  /// Throws an [Exception] if no placemarks are found or if an error occurs during the process.
  Future<UserPosition> getAddressFromLatLng(Position? position) async {
    position ??= await _determineUserPosition();

    try {
      List<Placemark> placeMarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placeMarks.isEmpty) {
        throw Exception("No placemarks found for the provided coordinates.");
      }

      return UserPosition(
          latitude: position.latitude,
          longitude: position.longitude,
          placemark: placeMarks.first);
    } catch (e) {
      throw Exception("Failed to retrieve address: $e");
    }
  }

  /// Saves the user's current [position] (latitude and longitude) to secure storage.
  ///
  /// The data is stored as strings using [FlutterSecureStorage].
  Future<void> saveLocation(UserPosition position) async {
    const FlutterSecureStorage storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
    await storage.write(key: "latitude", value: position.latitude.toString());
    await storage.write(key: "longitude", value: position.longitude.toString());
    await storage.write(key: "placemark", value: UserPosition.serializePlacemark(position.placemark));
  }

  /// Loads the user's saved location from secure storage and returns it as a [UserPosition].
  ///
  /// If no location data is found, returns a [UserPosition] with null latitude and longitude.
  Future<UserPosition> loadLocation() async {
    const FlutterSecureStorage storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
    String? latitude = await storage.read(key: "latitude");
    String? longitude = await storage.read(key: "longitude");
    String? placemarkString = await storage.read(key: "placemark");

    Placemark? placemark;
    if (placemarkString != null) {
      placemark = UserPosition.deserializePlacemark(placemarkString);
    }

    if (latitude == null || longitude == null) {
      return UserPosition(
          latitude: null, longitude: null, placemark: placemark);
    }

    return UserPosition(
        latitude: double.parse(latitude),
        longitude: double.parse(longitude),
        placemark: placemark);
  }

  /// Determines the user's current [Position] by checking the location service
  /// status and permissions before retrieving the position.
  ///
  /// Throws an [Exception] if location services are disabled or if permissions
  /// are not granted.
  Future<Position> _determineUserPosition() async {
    bool serviceEnabled;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    _checkLocationPermission();
    return await Geolocator.getCurrentPosition();
  }

  /// Checks and requests location permissions if necessary.
  ///
  /// Throws an [Exception] if the user denies permission or if permissions
  /// are permanently denied.
  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
            "Location permissions are denied."); //TODO: Add a more user-friendly message.
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          "Location permissions are permanently denied, we cannot request permissions.");
    }
  }

  /// Initializes the user location by attempting to load cached data.
  ///
  /// If valid cached location data (with non-null latitude and longitude) is found,
  /// it is set as the current position and listeners are notified.
  /// Otherwise, [_refreshLocation] is called to fetch the location from the service.
  Future<void> _initializeLocation() async {
    final cached = await loadLocation();

    if(cached.latitude != null && cached.longitude != null) {

      _currentPosition = cached;
      debugPrint("Loaded cached location: $_currentPosition");

      return;
    }

    // If no cached data is available, fetch the location from the service.
    await _refreshLocation();
  }

  /// Refreshes the user location by retrieving the current position and address.
  ///
  /// This method fetches the current address using the [LocationManager], updates
  /// the [_currentPosition], notifies listeners, and saves the new location data
  /// for future use. If an error occurs during this process, it logs the error.
  Future<void> _refreshLocation() async {
    try {
      final locationAddress =
          await getAddressFromLatLng(null);
      _currentPosition = locationAddress;

      await saveLocation(_currentPosition!);
    } catch (e) {
      debugPrint("Error initializing location: $e");
    }
  }
}
