import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nothing_clock/models/location_address.dart';

class LocationService {
  Future<Position> determineUserPosition() async {
    bool serviceEnabled;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

   _checkLocationPermission();
    return await Geolocator.getCurrentPosition();
  }

  Future<LocationAddress> getAddressFromLatLng(
      Position? position) async {
  
    position ??= await determineUserPosition();

    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if(placeMarks.isEmpty) {
        throw Exception("No placemarks found for the provided coordinates.");
      }

      return LocationAddress(position: position, placemark: placeMarks.first);
    } catch (e) {
      throw Exception("Failed to retrieve address: $e");
    }
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          "Location permissions are permanently denied, we cannot request permissions.");
    }
  }
}
