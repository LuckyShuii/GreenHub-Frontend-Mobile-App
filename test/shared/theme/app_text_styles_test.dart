import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/shared/theme/app_text_styles.dart';
import 'package:flutter_frontend/shared/theme/app_colors.dart';

void main() {
  group('AppTextStyles - Display', () {
    test('has correct font size', () {
      expect(AppTextStyles.display.fontSize, 36);
    });

    test('has correct font weight (w900)', () {
      expect(AppTextStyles.display.fontWeight, FontWeight.w900);
    });

    test('has correct line height', () {
      expect(AppTextStyles.display.height, 1.1);
    });

    test('has correct letter spacing', () {
      expect(AppTextStyles.display.letterSpacing, -0.5);
    });

    test('uses dark olive color', () {
      expect(AppTextStyles.display.color, AppColors.o900);
    });
  });

  group('AppTextStyles - Title', () {
    test('has correct font size', () {
      expect(AppTextStyles.title.fontSize, 26);
    });

    test('has correct font weight (w800)', () {
      expect(AppTextStyles.title.fontWeight, FontWeight.w800);
    });

    test('has correct line height', () {
      expect(AppTextStyles.title.height, 1.2);
    });

    test('uses dark olive color', () {
      expect(AppTextStyles.title.color, AppColors.o900);
    });
  });

  group('AppTextStyles - Subtitle', () {
    test('has correct font size', () {
      expect(AppTextStyles.subtitle.fontSize, 20);
    });

    test('has correct font weight (w700)', () {
      expect(AppTextStyles.subtitle.fontWeight, FontWeight.w700);
    });

    test('has correct line height', () {
      expect(AppTextStyles.subtitle.height, 1.3);
    });

    test('uses dark olive color', () {
      expect(AppTextStyles.subtitle.color, AppColors.o900);
    });
  });

  group('AppTextStyles - Body', () {
    test('has correct font size', () {
      expect(AppTextStyles.body.fontSize, 16);
    });

    test('has correct font weight (w400)', () {
      expect(AppTextStyles.body.fontWeight, FontWeight.w400);
    });

    test('has correct line height', () {
      expect(AppTextStyles.body.height, 1.45);
    });

    test('uses dark olive color', () {
      expect(AppTextStyles.body.color, AppColors.o900);
    });
  });

  group('AppTextStyles - Label', () {
    test('has correct font size', () {
      expect(AppTextStyles.label.fontSize, 12);
    });

    test('has correct font weight (w700)', () {
      expect(AppTextStyles.label.fontWeight, FontWeight.w700);
    });

    test('has correct line height', () {
      expect(AppTextStyles.label.height, 1.4);
    });

    test('has letter spacing', () {
      expect(AppTextStyles.label.letterSpacing, 0.5);
    });

    test('uses medium olive color', () {
      expect(AppTextStyles.label.color, AppColors.o700);
    });
  });

  group('AppTextStyles - BodySmall', () {
    test('has correct font size', () {
      expect(AppTextStyles.bodySmall.fontSize, 14);
    });

    test('has correct font weight (w400)', () {
      expect(AppTextStyles.bodySmall.fontWeight, FontWeight.w400);
    });

    test('has correct line height', () {
      expect(AppTextStyles.bodySmall.height, 1.4);
    });

    test('uses medium olive color', () {
      expect(AppTextStyles.bodySmall.color, AppColors.o700);
    });
  });

  group('AppTextStyles - Consistency', () {
    test('all styles have defined colors', () {
      expect(AppTextStyles.display.color, isNotNull);
      expect(AppTextStyles.title.color, isNotNull);
      expect(AppTextStyles.body.color, isNotNull);
    });

    test('all styles have defined font sizes', () {
      expect(AppTextStyles.display.fontSize, isNotNull);
      expect(AppTextStyles.title.fontSize, isNotNull);
      expect(AppTextStyles.body.fontSize, isNotNull);
    });

    test('all styles have defined font weights', () {
      expect(AppTextStyles.display.fontWeight, isNotNull);
      expect(AppTextStyles.title.fontWeight, isNotNull);
      expect(AppTextStyles.body.fontWeight, isNotNull);
    });

    test('font sizes are in descending order', () {
      expect(AppTextStyles.display.fontSize,
          greaterThan(AppTextStyles.title.fontSize!));
      expect(AppTextStyles.title.fontSize,
          greaterThan(AppTextStyles.subtitle.fontSize!));
      expect(AppTextStyles.subtitle.fontSize,
          greaterThan(AppTextStyles.body.fontSize!));
      expect(
          AppTextStyles.body.fontSize, greaterThan(AppTextStyles.label.fontSize!));
    });
  });
}
