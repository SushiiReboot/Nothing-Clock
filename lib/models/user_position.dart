import 'dart:convert';

import 'package:geocoding/geocoding.dart';

/// A model that represents the user's geographic position, including
/// latitude, longitude, and an optional placemark with detailed address information.
class UserPosition {

  /// The latitude of the user's position.
  final double? latitude;

  /// The longitude of the user's position.
  final double? longitude;

  /// An optional [Placemark] containing address details for the position.
  final Placemark? placemark;

  /// Creates a [UserPosition] with the given [latitude], [longitude], and an optional [placemark].
  UserPosition({this.placemark, required this.latitude, required this.longitude});

  /// Creates a [UserPosition] from a JSON [Map].
  ///
  /// The JSON should contain numeric values for 'latitude' and 'longitude'.
  factory UserPosition.fromJson(Map<String, dynamic> json) {
    return UserPosition(
      latitude: json['latitude'] is double
          ? json['latitude'] as double
          : (json['latitude'] as num?)?.toDouble(),
      longitude: json['longitude'] is double
          ? json['longitude'] as double
          : (json['longitude'] as num?)?.toDouble(),
    );
  }

  /// Serializes the given [placemark] into a JSON string.
  ///
  /// This method extracts key address details from the [placemark] and encodes them
  /// into a JSON string.
  static String serializePlacemark(Placemark? placemark) {

    if(placemark == null) {
      return '{}';
    }

    final Map<String, dynamic> data = {
        'name': placemark.name,
        'street': placemark.street,
        'subLocality': placemark.subLocality,
        'locality': placemark.locality,
        'subAdministrativeArea': placemark.subAdministrativeArea,
        'administrativeArea': placemark.administrativeArea,
        'postalCode': placemark.postalCode,
        'country': placemark.country,
        'isoCountryCode': placemark.isoCountryCode,
    };

    return jsonEncode(data);
  }

  /// Deserializes a JSON string [jsonData] into a [Placemark] object.
  ///
  /// The JSON string must contain the same keys as produced by [serializePlacemark].
  static Placemark deserializePlacemark(String jsonData) {
    final Map<String, dynamic> data = jsonDecode(jsonData);
    return Placemark(
      name: data['name'],
      street: data['street'],
      subLocality: data['subLocality'],
      locality: data['locality'],
      subAdministrativeArea: data['subAdministrativeArea'],
      administrativeArea: data['administrativeArea'],
      postalCode: data['postalCode'],
      country: data['country'],
      isoCountryCode: data['isoCountryCode'],
    );
  }

  /// Converts the [UserPosition] into a JSON [Map].
  ///
  /// Note: The [placemark] is not included in the JSON representation.
  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}