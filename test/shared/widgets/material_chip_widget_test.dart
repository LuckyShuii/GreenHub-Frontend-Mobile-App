import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/shared/widgets/material_chip_widget.dart' as chip;

void main() {
  group('MaterialChipWidget', () {
    testWidgets('renders with material type label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: chip.MaterialChipWidget(
              materialType: chip.MaterialType.verre,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Verre'), findsOneWidget);
      expect(find.byType(FilterChip), findsOneWidget);
    });

    testWidgets('renders all material types correctly', (WidgetTester tester) async {
      final materialTypes = [
        chip.MaterialType.verre,
        chip.MaterialType.plastique,
        chip.MaterialType.carton,
        chip.MaterialType.metal,
      ];

      for (final type in materialTypes) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: chip.MaterialChipWidget(
                materialType: type,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text(type.label), findsOneWidget);
      }
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: chip.MaterialChipWidget(
              materialType: chip.MaterialType.verre,
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FilterChip));
      await tester.pumpAndSettle();

      expect(wasPressed, true);
    });

    testWidgets('shows selected state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: chip.MaterialChipWidget(
              materialType: chip.MaterialType.plastique,
              isSelected: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      final filterChip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(filterChip.selected, true);
    });

    testWidgets('shows unselected state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: chip.MaterialChipWidget(
              materialType: chip.MaterialType.plastique,
              isSelected: false,
              onPressed: () {},
            ),
          ),
        ),
      );

      final filterChip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(filterChip.selected, false);
    });

    testWidgets('toggles selection when tapped', (WidgetTester tester) async {
      bool isSelected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return chip.MaterialChipWidget(
                  materialType: chip.MaterialType.carton,
                  isSelected: isSelected,
                  onPressed: () => setState(() => isSelected = !isSelected),
                );
              },
            ),
          ),
        ),
      );

      expect(isSelected, false);

      await tester.tap(find.byType(FilterChip));
      await tester.pumpAndSettle();

      expect(isSelected, true);
    });

    testWidgets('all material types have correct colors', (WidgetTester tester) async {
      expect(chip.MaterialType.verre.color, isNotNull);
      expect(chip.MaterialType.plastique.color, isNotNull);
      expect(chip.MaterialType.carton.color, isNotNull);
      expect(chip.MaterialType.metal.color, isNotNull);
    });

    testWidgets('all material types have correct labels', (WidgetTester tester) async {
      expect(chip.MaterialType.verre.label, 'Verre');
      expect(chip.MaterialType.plastique.label, 'Plastique');
      expect(chip.MaterialType.carton.label, 'Carton');
      expect(chip.MaterialType.metal.label, 'Métal');
    });
  });
}
