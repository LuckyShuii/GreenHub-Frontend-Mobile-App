import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/shared/theme/app_colors.dart';

void main() {
  group('AppColors - Vert Greener (Primaire)', () {
    test('v900 is darkest green', () {
      expect(AppColors.v900, const Color(0xFF1C443B));
    });

    test('v700 is primary green', () {
      expect(AppColors.v700, const Color(0xFF2F6B46));
    });

    test('v500 is medium green', () {
      expect(AppColors.v500, const Color(0xFF4F8A63));
    });

    test('v300 is light green', () {
      expect(AppColors.v300, const Color(0xFF8B9B82));
    });

    test('v100 is very light green', () {
      expect(AppColors.v100, const Color(0xFFD7E0CF));
    });

    test('v50 is lightest green', () {
      expect(AppColors.v50, const Color(0xFFEEF2E9));
    });
  });

  group('AppColors - Neutre Olive (Surfaces & Texte)', () {
    test('o900 is darkest olive', () {
      expect(AppColors.o900, const Color(0xFF23291F));
    });

    test('o700 is dark olive for text', () {
      expect(AppColors.o700, const Color(0xFF3C4239));
    });

    test('o500 is medium olive', () {
      expect(AppColors.o500, const Color(0xFF6F766A));
    });

    test('o300 is light olive', () {
      expect(AppColors.o300, const Color(0xFFB9BDB2));
    });

    test('o100 is very light olive', () {
      expect(AppColors.o100, const Color(0xFFE2E4DF));
    });

    test('o50 is lightest olive (background)', () {
      expect(AppColors.o50, const Color(0xFFF4F5F1));
    });
  });

  group('AppColors - Accents Matières (Tri Sélectif)', () {
    test('verre is red/pink for glass', () {
      expect(AppColors.verre, const Color(0xFFC2615F));
    });

    test('plastique is purple for plastic', () {
      expect(AppColors.plastique, const Color(0xFF7A76C4));
    });

    test('carton is gold for cardboard', () {
      expect(AppColors.carton, const Color(0xFFD8A93A));
    });

    test('metal is blue for metal', () {
      expect(AppColors.metal, const Color(0xFF5B86C4));
    });
  });

  group('AppColors - Sémantique', () {
    test('succes is green (success state)', () {
      expect(AppColors.succes, const Color(0xFF2F6B46));
      expect(AppColors.succes, equals(AppColors.v700));
    });

    test('alerte is gold (alert state)', () {
      expect(AppColors.alerte, const Color(0xFFD8A93A));
      expect(AppColors.alerte, equals(AppColors.carton));
    });

    test('erreur is red (error state)', () {
      expect(AppColors.erreur, const Color(0xFFC2473F));
    });

    test('info is blue (info state)', () {
      expect(AppColors.info, const Color(0xFF5B86C4));
      expect(AppColors.info, equals(AppColors.metal));
    });
  });

  group('AppColors - Alias pour compatibilité', () {
    test('primary is v700', () {
      expect(AppColors.primary, equals(AppColors.v700));
    });

    test('secondary is v500', () {
      expect(AppColors.secondary, equals(AppColors.v500));
    });

    test('tertiary is v300', () {
      expect(AppColors.tertiary, equals(AppColors.v300));
    });

    test('surface is o50', () {
      expect(AppColors.surface, equals(AppColors.o50));
    });

    test('background is o50', () {
      expect(AppColors.background, equals(AppColors.o50));
    });

    test('error is erreur', () {
      expect(AppColors.error, equals(AppColors.erreur));
    });

    test('onSurface is o900', () {
      expect(AppColors.onSurface, equals(AppColors.o900));
    });

    test('onBackground is o900', () {
      expect(AppColors.onBackground, equals(AppColors.o900));
    });
  });

  group('AppColors - Gradient', () {
    test('heroGradient has two colors', () {
      expect(AppColors.heroGradient.colors.length, 2);
    });

    test('heroGradient has light green colors', () {
      expect(AppColors.heroGradient.colors[0], const Color(0xFFE9F8EF));
      expect(AppColors.heroGradient.colors[1], const Color(0xFFF8FAF7));
    });

    test('heroGradient starts from top-left', () {
      expect(AppColors.heroGradient.begin, Alignment.topLeft);
    });

    test('heroGradient ends at bottom-right', () {
      expect(AppColors.heroGradient.end, Alignment.bottomRight);
    });
  });

  group('AppColors - Consistency', () {
    test('all colors have defined opacity', () {
      expect(AppColors.v900, isNotNull);
      expect(AppColors.o900, isNotNull);
      expect(AppColors.erreur, isNotNull);
    });

    test('color values are valid', () {
      expect(AppColors.v900.value, isNotNull);
      expect(AppColors.o900.value, isNotNull);
    });
  });
}
