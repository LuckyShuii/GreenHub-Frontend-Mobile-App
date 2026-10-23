import 'package:flutter/material.dart';

/// Badge coloré pour un score en lettre (A à E) — Nutri-score, Eco-score,
/// ou tout score du même type. Palette calée sur le code couleur standard.
class ProductScoreBadgeWidget extends StatelessWidget {
  const ProductScoreBadgeWidget({required this.grade, super.key});

  final String grade;

  static const Map<String, Color> _colors = <String, Color>{
    'A': Color(0xFF1E8F4E),
    'B': Color(0xFF6CB33F),
    'C': Color(0xFFF4C430),
    'D': Color(0xFFE8792C),
    'E': Color(0xFFD23C3C),
  };

  @override
  Widget build(BuildContext context) {
    final Color color = _colors[grade.toUpperCase()] ?? Colors.grey;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        grade.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
