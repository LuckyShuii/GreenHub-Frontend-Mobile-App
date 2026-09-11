import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/shared/theme/app_spacing.dart';

void main() {
  group('AppSpacing', () {
    test('xxs is 4', () {
      expect(AppSpacing.xxs, 4);
    });

    test('xs is 8', () {
      expect(AppSpacing.xs, 8);
    });

    test('sm is 12', () {
      expect(AppSpacing.sm, 12);
    });

    test('md is 16', () {
      expect(AppSpacing.md, 16);
    });

    test('lg is 24', () {
      expect(AppSpacing.lg, 24);
    });

    test('xl is 32', () {
      expect(AppSpacing.xl, 32);
    });

    test('xxl is 40', () {
      expect(AppSpacing.xxl, 40);
    });

    test('spacing values are in ascending order', () {
      expect(AppSpacing.xxs, lessThan(AppSpacing.xs));
      expect(AppSpacing.xs, lessThan(AppSpacing.sm));
      expect(AppSpacing.sm, lessThan(AppSpacing.md));
      expect(AppSpacing.md, lessThan(AppSpacing.lg));
      expect(AppSpacing.lg, lessThan(AppSpacing.xl));
      expect(AppSpacing.xl, lessThan(AppSpacing.xxl));
    });

    test('spacing values are multiples of 4 (base unit)', () {
      expect(AppSpacing.xxs % 4, 0);
      expect(AppSpacing.xs % 4, 0);
      expect(AppSpacing.sm % 4, 0);
      expect(AppSpacing.md % 4, 0);
      expect(AppSpacing.lg % 4, 0);
      expect(AppSpacing.xl % 4, 0);
      expect(AppSpacing.xxl % 4, 0);
    });

    test('spacing increments are consistent', () {
      expect(AppSpacing.xs - AppSpacing.xxs, 4); // +4
      expect(AppSpacing.sm - AppSpacing.xs, 4); // +4
      expect(AppSpacing.md - AppSpacing.sm, 4); // +4
      expect(AppSpacing.lg - AppSpacing.md, 8); // +8
      expect(AppSpacing.xl - AppSpacing.lg, 8); // +8
      expect(AppSpacing.xxl - AppSpacing.xl, 8); // +8
    });

    test('spacing values are positive', () {
      expect(AppSpacing.xxs, greaterThan(0));
      expect(AppSpacing.xs, greaterThan(0));
      expect(AppSpacing.sm, greaterThan(0));
      expect(AppSpacing.md, greaterThan(0));
      expect(AppSpacing.lg, greaterThan(0));
      expect(AppSpacing.xl, greaterThan(0));
      expect(AppSpacing.xxl, greaterThan(0));
    });

    test('all spacing values are doubles', () {
      expect(AppSpacing.xxs is double, isTrue);
      expect(AppSpacing.xs is double, isTrue);
      expect(AppSpacing.sm is double, isTrue);
      expect(AppSpacing.md is double, isTrue);
      expect(AppSpacing.lg is double, isTrue);
      expect(AppSpacing.xl is double, isTrue);
      expect(AppSpacing.xxl is double, isTrue);
    });
  });
}
