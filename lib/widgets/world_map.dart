import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WorldMap extends StatelessWidget {
  const WorldMap({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 300,
        color: Colors.black,
        child: SvgPicture.asset(
          "lib/assets/map/map.svg",
          width: 400,
          colorFilter: const ColorFilter.mode(
              Color.fromARGB(255, 85, 85, 85), BlendMode.srcIn),
        ));
  }
}
