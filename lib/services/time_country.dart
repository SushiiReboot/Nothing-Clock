import 'dart:convert';

import 'package:flutter/services.dart';

class TimeCountry {
  static List<dynamic>? data;

  static Future<List<dynamic>> _loadJsonFromAssets() async {
    String jsonString = await rootBundle
        .loadString("lib/assets/map/data/countries_coords.json");

    List<dynamic> jsonData = json.decode(jsonString);

    return jsonData;
  }

  static List<double>? getLatLngByCountryName(String countryName) {
    data = getData();

    for (var country in data!) {
      String commonName = country['name']['common'].toString().toLowerCase();
      String officialName =
          country['name']['official'].toString().toLowerCase();

      if (countryName.toLowerCase() == commonName ||
          countryName.toLowerCase() == officialName) {
        return List<double>.from(country['latlng']);
      }
    }

    print("country not found for $countryName");
    return null; // Return null if the country is not found
  }

  static List<dynamic>? getData() {
    return data;
  }

  static Future<void> init() async {
    data = await _loadJsonFromAssets();
  }
}
