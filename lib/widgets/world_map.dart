import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nothing_clock/providers/theme_provider.dart';
import 'package:nothing_clock/providers/worldclocks_provider.dart';
import 'package:nothing_clock/services/dot_map_converter.dart';
import 'package:nothing_clock/services/location_manager.dart';
import 'package:provider/provider.dart';

class WorldMap extends StatelessWidget {
  const WorldMap({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final worldClocksProvider = Provider.of<WorldClocksProvider>(context);
    
    // Get current location coordinates
    final locationManager = LocationManager();
    final currentPosition = locationManager.currentPosition;
    Offset currentLocationCoords = currentPosition?.latitude != null && currentPosition?.longitude != null
        ? DotMapConverter.convertCoordsToMapCoords(
            currentPosition!.latitude!, currentPosition.longitude!)
        : DotMapConverter.convertCoordsToMapCoords(0, 0); // Default if no location

    final otherLocationPinColor = themeProvider.isDarkMode
        ? const Color.fromARGB(255, 255, 255, 255)
        : const Color.fromARGB(255, 250, 134, 2);

    return Stack(
      children: [
        Container(
          color: Colors.transparent,
          child: SvgPicture.asset(
            width: 370,
            "lib/assets/map/map.svg",
            colorFilter: ColorFilter.mode(
              themeProvider.isDarkMode
                  ? const Color.fromARGB(255, 59, 59, 59)
                  : Colors.black,
              BlendMode.srcIn,
            ),
          ),
        ),
        // Add current location dot (red)
        _addDotToMap(
          currentLocationCoords.dx - 1, 
          currentLocationCoords.dy - 2, 
          true, 
          Colors.red,
          otherLocationPinColor
        ),
        
        // Add dots for all world clocks (white)
        ...worldClocksProvider.worldClocks.map((clock) {
          final clockCoords = DotMapConverter.convertCoordsToMapCoords(
            clock.latitude, 
            clock.longitude
          );
          return _addDotToMap(
            clockCoords.dx - 1, 
            clockCoords.dy - 2, 
            false, 
            Colors.red,
            otherLocationPinColor
          );
        }).toList(),
      ],
    );
  }
}

Positioned _addDotToMap(double xCoord, double yCoord, bool isCurrentLocation,
    Color currentLocationColor, Color otherLocationColor) {
  // Here you convert your map coordinates to pixel coordinates
  // For a 62x28 map, the logic for converting coordinates could vary depending on how the map is scaled
  // The provided code adds a dot by positioning it on the map at (xCoord, yCoord)

  // Let's assume you want to scale the xCoord and yCoord to fit your map.
  // For example, the map has 62 units width and 28 units height, and we use scale factors to convert them.

  return Positioned(
    left: xCoord * 6,
    top: yCoord * 6,
    child: Container(
      width: isCurrentLocation ? 12 : 8,
      height: isCurrentLocation ? 12 : 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCurrentLocation ? currentLocationColor : otherLocationColor,
      ),
    ),
  );
}
