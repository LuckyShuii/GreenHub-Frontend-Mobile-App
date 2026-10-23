import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MarkerColorMapper extends ColorMapper {
  final Color color;

  const MarkerColorMapper(this.color);

  @override
  Color substitute(
      String? id,
      String elementName,
      String attributeName,
      Color originalColor,
      ) {
    if (id == 'marker-fill' && attributeName == 'fill') {
      return color;
    }

    return originalColor;
  }
}

class CustomMapMarker extends StatelessWidget {
  final Color color;
  final double size;

  const CustomMapMarker({
    super.key,
    required this.color,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/location-07.svg',
      width: size,
      height: size,
      colorMapper: MarkerColorMapper(color),
    );
  }
}