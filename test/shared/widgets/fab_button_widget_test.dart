import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/shared/widgets/fab_button_widget.dart';

void main() {
  group('FABButtonWidget', () {
    testWidgets('renders with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABButtonWidget(
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(FABButtonWidget), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABButtonWidget(
              icon: Icons.add,
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(wasPressed, true);
    });

    testWidgets('renders circular shape', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABButtonWidget(
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('uses default background color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABButtonWidget(
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNotNull);
    });

    testWidgets('uses custom background color', (WidgetTester tester) async {
      const customColor = Color(0xFFE53935);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABButtonWidget(
              icon: Icons.add,
              onPressed: () {},
              backgroundColor: customColor,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, customColor);
    });

    testWidgets('uses custom foreground color', (WidgetTester tester) async {
      const customColor = Color(0xFF000000);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABButtonWidget(
              icon: Icons.add,
              onPressed: () {},
              foregroundColor: customColor,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, customColor);
    });

    testWidgets('has default size of 56', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABButtonWidget(
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, 56);
      expect(container.constraints?.maxHeight, 56);
    });

    testWidgets('uses custom size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABButtonWidget(
              icon: Icons.add,
              onPressed: () {},
              size: 64,
            ),
          ),
        ),
      );

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('has shadow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABButtonWidget(
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow?.isNotEmpty, true);
    });

    testWidgets('icon has correct size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FABButtonWidget(
              icon: Icons.edit,
              onPressed: () {},
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, 24);
    });

    testWidgets('renders multiple icons correctly', (WidgetTester tester) async {
      final icons = [Icons.add, Icons.edit, Icons.delete, Icons.search];

      for (final icon in icons) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FABButtonWidget(
                icon: icon,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(icon), findsOneWidget);
      }
    });
  });
}
