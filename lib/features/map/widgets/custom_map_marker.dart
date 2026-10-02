import 'package:flutter/material.dart';
import '../models/map_marker_type.dart';

class CustomMapMarker extends StatelessWidget {
  final MapMarkerType type;

  const CustomMapMarker({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      type.icon,
      color: type.color,
      size: 30,
    );
  }
}