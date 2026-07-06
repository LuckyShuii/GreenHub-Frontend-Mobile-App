import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/shared/theme/app_radii.dart';

void main() {
  group('AppRadii', () {
    test('sm is 8', () {
      expect(AppRadii.sm, 8);
    });

    test('md is 16', () {
      expect(AppRadii.md, 16);
    });

    test('lg is 22', () {
      expect(AppRadii.lg, 22);
    });

    test('pill is 999 (circular)', () {
      expect(AppRadii.pill, 999);
    });

    test('radii are in ascending order', () {
      expect(AppRadii.sm, lessThan(AppRadii.md));
      expect(AppRadii.md, lessThan(AppRadii.lg));
      expect(AppRadii.lg, lessThan(AppRadii.pill));
    });

    test('radii values are positive', () {
      expect(AppRadii.sm, greaterThan(0));
      expect(AppRadii.md, greaterThan(0));
      expect(AppRadii.lg, greaterThan(0));
      expect(AppRadii.pill, greaterThan(0));
    });

    test('all radii values are doubles', () {
      expect(AppRadii.sm is double, isTrue);
      expect(AppRadii.md is double, isTrue);
      expect(AppRadii.lg is double, isTrue);
      expect(AppRadii.pill is double, isTrue);
    });

    test('pill radius is appropriate for circular elements', () {
      // 999 is large enough to create a circle regardless of container size
      expect(AppRadii.pill, greaterThan(100));
    });

    test('sm is suitable for small elements', () {
      expect(AppRadii.sm, greaterThan(0));
      expect(AppRadii.sm, lessThan(12));
    });

    test('md is suitable for medium elements', () {
      expect(AppRadii.md, greaterThan(8));
      expect(AppRadii.md, lessThan(24));
    });

    test('lg is suitable for large elements', () {
      expect(AppRadii.lg, greaterThan(16));
      expect(AppRadii.lg, lessThan(32));
    });
  });
}
