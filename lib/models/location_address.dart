import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// A model that encapsulates both a [Position] and its corresponding [Placemark].
class LocationAddress {
  final Position position;
  final Placemark placemark;

  LocationAddress({required this.position, required this.placemark});

  Map<String, dynamic> toMap() {
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'placemark': {
        'name': placemark.name,
        'street': placemark.street,
        'locality': placemark.locality,
        'subLocality': placemark.subLocality,
        'administrativeArea': placemark.administrativeArea,
        'postalCode': placemark.postalCode,
        'country': placemark.country,
      }
    };
  }

  factory LocationAddress.fromMap(Map<String, dynamic> map) {
    return LocationAddress(
      position: Position(
        latitude: map['latitude'],
        longitude: map['longitude'],
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      ),
      placemark: Placemark(
        name: map['placemark']['name'],
        street: map['placemark']['street'],
        locality: map['placemark']['locality'],
        subLocality: map['placemark']['subLocality'],
        administrativeArea: map['placemark']['administrativeArea'],
        postalCode: map['placemark']['postalCode'],
        country: map['placemark']['country'],
      ),
    );
  }
}
