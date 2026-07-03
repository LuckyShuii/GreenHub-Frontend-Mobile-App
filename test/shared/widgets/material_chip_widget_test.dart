import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/shared/widgets/material_chip_widget.dart';

void main() {
  group('MaterialChipWidget', () {
    testWidgets('renders with material type label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialChipWidget(
              materialType: MaterialType.verre,
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
        MaterialType.verre,
        MaterialType.plastique,
        MaterialType.carton,
        MaterialType.metal,
      ];

      for (final type in materialTypes) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MaterialChipWidget(
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
            body: MaterialChipWidget(
              materialType: MaterialType.verre,
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
            body: MaterialChipWidget(
              materialType: MaterialType.plastique,
              isSelected: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      final chip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(chip.selected, true);
    });

    testWidgets('shows unselected state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialChipWidget(
              materialType: MaterialType.plastique,
              isSelected: false,
              onPressed: () {},
            ),
          ),
        ),
      );

      final chip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(chip.selected, false);
    });

    testWidgets('toggles selection when tapped', (WidgetTester tester) async {
      bool isSelected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return MaterialChipWidget(
                  materialType: MaterialType.carton,
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
      expect(MaterialType.verre.color, isNotNull);
      expect(MaterialType.plastique.color, isNotNull);
      expect(MaterialType.carton.color, isNotNull);
      expect(MaterialType.metal.color, isNotNull);
    });

    testWidgets('all material types have correct labels', (WidgetTester tester) async {
      expect(MaterialType.verre.label, 'Verre');
      expect(MaterialType.plastique.label, 'Plastique');
      expect(MaterialType.carton.label, 'Carton');
      expect(MaterialType.metal.label, 'Métal');
    });
  });
}
