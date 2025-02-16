import 'dart:math';
import 'dart:ui';

class DotMapConverter {
  static Offset convertCoordsToMapCoords(double lat, double lng) {
    SphericalMercator mercator = SphericalMercator();

    final double xKyiv = mercator.xAxisProjection(lng);
    final double yKyiv = mercator.yAxisProjection(lat);

    const int mapWidth = 62;
    const int mapHeight = 28;

    // Scale the coordinates to fit the 62x28 map
    final double xScaledKyiv = ((xKyiv + pi * SphericalMercator.radiusMajor) /
        (2 * pi * SphericalMercator.radiusMajor) *
        mapWidth);
    final double yScaledKyiv = mapHeight -
        1 -
        ((yKyiv + pi * SphericalMercator.radiusMajor) /
            (2 * pi * SphericalMercator.radiusMajor) *
            mapHeight);

    return Offset(xScaledKyiv, yScaledKyiv);
  }
}

class SphericalMercator {
  static const double radiusMajor =
      6378137.0; // Earth's radius in meters for WGS84

  double xAxisProjection(double input) {
    return radians(input) * radiusMajor;
  }

  double yAxisProjection(double input) {
    return log(tan(pi / 4 + radians(input) / 2)) * radiusMajor;
  }

  double radians(double degrees) => degrees * (pi / 180.0);
}
