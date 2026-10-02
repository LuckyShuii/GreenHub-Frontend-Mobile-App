import 'package:flutter/material.dart';

enum MapMarkerType {
  velib(
    icon: Icons.pedal_bike,
    color: Colors.blue,
  ),

  verre(
    icon: Icons.wine_bar,
    color: Colors.green,
  ),

  plastique(
    icon: Icons.recycling,
    color: Colors.orange,
  ),

  papier(
    icon: Icons.description,
    color: Colors.blue,
  ),

  vetements(
    icon: Icons.checkroom,
    color: Colors.purple,
  ),

  piles(
    icon: Icons.battery_full,
    color: Colors.red,
  ),

  metaux(
    icon: Icons.hardware,
    color: Colors.grey,
  ),

  dechetterie(
    icon: Icons.delete,
    color: Colors.black,
  );

  final IconData icon;
  final Color color;

  const MapMarkerType({
    required this.icon,
    required this.color,
  });
}