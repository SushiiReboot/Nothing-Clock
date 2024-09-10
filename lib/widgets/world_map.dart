import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nothing_clock/services/dot_map_converter.dart';

class WorldMap extends StatelessWidget {
  const WorldMap({super.key});

  @override
  Widget build(BuildContext context) {
    Offset mapCoords =
        DotMapConverter.convertCoordsToMapCoords(40.7128, -74.0060);

    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: SvgPicture.asset(
            width: 370,
            "lib/assets/map/map.svg",
            colorFilter: const ColorFilter.mode(
              Color.fromARGB(255, 85, 85, 85),
              BlendMode.srcIn,
            ),
          ),
        ),
        _addDotToMap(mapCoords.dx - 1, mapCoords.dy - 2)
      ],
    );
  }

  // You can use the rest of your original code here
}

Positioned _addDotToMap(double xCoord, double yCoord) {
  // Here you convert your map coordinates to pixel coordinates
  // For a 62x28 map, the logic for converting coordinates could vary depending on how the map is scaled
  // The provided code adds a dot by positioning it on the map at (xCoord, yCoord)

  // Let's assume you want to scale the xCoord and yCoord to fit your map.
  // For example, the map has 62 units width and 28 units height, and we use scale factors to convert them.

  return Positioned(
    left: xCoord * 6,
    top: yCoord * 6,
    child: Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
      ),
    ),
  );
}
