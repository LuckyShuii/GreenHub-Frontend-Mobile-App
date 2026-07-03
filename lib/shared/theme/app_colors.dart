import 'package:flutter/material.dart';

class AppColors {
  // Vert Greener - Primaire
  static const Color v900 = Color(0xFF1C443B);
  static const Color v700 = Color(0xFF2F6B46);
  static const Color v500 = Color(0xFF4F8A63);
  static const Color v300 = Color(0xFF8B9B82);
  static const Color v100 = Color(0xFFD7E0CF);
  static const Color v50 = Color(0xFFEEF2E9);

  // Neutre Olive - surfaces et texte
  static const Color o900 = Color(0xFF23291F);
  static const Color o700 = Color(0xFF3C4239);
  static const Color o500 = Color(0xFF6F766A);
  static const Color o300 = Color(0xFFB9BDB2);
  static const Color o100 = Color(0xFFE2E4DF);
  static const Color o50 = Color(0xFFF4F5F1);

  // Accents matières (tri sélectif)
  static const Color verre = Color(0xFFC2615F);
  static const Color plastique = Color(0xFF7A76C4);
  static const Color carton = Color(0xFFD8A93A);
  static const Color metal = Color(0xFF5B86C4);

  // Sémantique
  static const Color succes = Color(0xFF2F6B46);
  static const Color alerte = Color(0xFFD8A93A);
  static const Color erreur = Color(0xFFC2473F);
  static const Color info = Color(0xFF5B86C4);

  // Alias pour compatibilité avec le thème
  static const Color primary = v700;
  static const Color secondary = v500;
  static const Color tertiary = v300;
  static const Color surface = o50;
  static const Color background = o50;
  static const Color error = erreur;
  static const Color onSurface = o900;
  static const Color onBackground = o900;

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    colors: <Color>[Color(0xFFE9F8EF), Color(0xFFF8FAF7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
