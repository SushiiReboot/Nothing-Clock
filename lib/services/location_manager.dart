import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nothing_clock/models/user_position.dart';
import 'package:worldtime/worldtime.dart';

/// A service class that handles retrieving, saving, and caching
/// user location data. It determines the current position,
/// converts coordinates into an address, and manages persistence
/// via secure storage. The class is implemented as a singleton so that
/// the location is only fetched once and shared throughout the app.
class LocationManager {
  /// The single instance of [LocationManager].
  static final LocationManager _instance = LocationManager._internal();

  /// The cached user position including latitude, longitude, UTC offset,
  /// and optionally a placemark (address details).
  UserPosition? _currentPosition;

  /// Public getter for the current user position.
  UserPosition? get currentPosition => _currentPosition;

  /// A future that completes when the location is initialized.
  late final Future<void> initialization;

  /// Private named constructor for initializing the singleton instance.
  ///
  /// If [currentPosition] is not already set, it triggers asynchronous
  /// initialization via [_initializeLocation] to load cached data or
  /// fetch the current location.
  LocationManager._internal() {
    if (currentPosition == null) {
      initialization = _initializeLocation();
    }
  }

  /// Factory constructor that always returns the same instance.
  factory LocationManager() {
    return _instance;
  }

  /// Converts a [Position] (from geolocator) into a [UserPosition] by
  /// fetching a corresponding [Placemark] using the provided latitude
  /// and longitude. If [position] is null, [_determineUserPosition] is called.
  ///
  /// Throws an [Exception] if no placemarks are found or if an error occurs.
  Future<UserPosition> getAddressFromLatLng(Position? position) async {
    
    // If position is null, fetch the current location.
    position ??= await _determineUserPosition();

    try {
      // Retrieve the list of placemarks based on the coordinates.
      List<Placemark> placeMarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placeMarks.isEmpty) {
        throw Exception("No placemarks found for the provided coordinates.");
      }

      // Retrieve the UTC offset using the worldtime package.
      int? utcOffset = await _getUtcOffset(position.latitude, position.longitude);

      // Return a new UserPosition with the fetched data.
      return UserPosition(
          latitude: position.latitude,
          longitude: position.longitude,
          utcOffset: utcOffset,
          placemark: placeMarks.first);
    } catch (e) {
      throw Exception("Failed to retrieve address: $e");
    }
  }

  /// Saves the provided [UserPosition] to secure storage using
  /// [FlutterSecureStorage]. The data is stored as strings.
  ///
  /// Uses Android's EncryptedSharedPreferences for secure storage.
  Future<void> saveLocation(UserPosition position) async {
    const FlutterSecureStorage storage = FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true));
    await storage.write(key: "latitude", value: position.latitude.toString());
    await storage.write(key: "longitude", value: position.longitude.toString());
    await storage.write(
        key: "placemark",
        value: UserPosition.serializePlacemark(position.placemark));
    await storage.write(key: "utcOffset", value: position.utcOffset.toString());
  }

  /// Loads the user's saved location from secure storage and returns it as
  /// a [UserPosition]. If any of the core fields are missing, a [UserPosition]
  /// with null coordinates and a UTC offset of 0 is returned.
  Future<UserPosition> loadLocation() async {
    const FlutterSecureStorage storage = FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true));
    String? latitude = await storage.read(key: "latitude");
    String? longitude = await storage.read(key: "longitude");
    String? utcOffset = await storage.read(key: "utcOffset");
    String? placemarkString = await storage.read(key: "placemark");

    Placemark? placemark;
    if (placemarkString != null) {
      placemark = UserPosition.deserializePlacemark(placemarkString);
    }

    // If essential data is missing, return a UserPosition with null coordinates.
    if (latitude == null || longitude == null || utcOffset == null) {
      UserPosition userPosition = UserPosition(
          latitude: null, longitude: null, placemark: placemark, utcOffset: 0);

      _currentPosition = userPosition;
      return userPosition;
    }

    // Parse the stored values and create a UserPosition.
    UserPosition userPosition = UserPosition(
        latitude: double.parse(latitude),
        longitude: double.parse(longitude),
        utcOffset: int.parse(utcOffset),
        placemark: placemark);

    _currentPosition = userPosition;
    return userPosition;
  }

  /// Returns the UTC offset (in hours) for the given [latitude] and [longitude].
  ///
  /// If the UTC offset is already cached in [_currentPosition], it returns that value.
  /// Otherwise, it uses the [Worldtime] package to determine the time zone offset.
  Future<int?> _getUtcOffset(double latitude, double longitude) async {
    if(_currentPosition?.utcOffset != null) {
      return _currentPosition?.utcOffset!;
    }

    final value = await Worldtime().timeByLocation(
      latitude: latitude,
      longitude: longitude,
    );

    return value.timeZoneOffset.inHours;
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

    if (cached.latitude != null && cached.longitude != null) {
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
      final locationAddress = await getAddressFromLatLng(null);
      _currentPosition = locationAddress;

      await saveLocation(_currentPosition!);
    } catch (e) {
      debugPrint("Error initializing location: $e");
    }
  }
}
