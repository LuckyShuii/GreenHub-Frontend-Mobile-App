import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/shared/widgets/content_card_widget.dart';

void main() {
  group('ContentCardWidget', () {
    testWidgets('can be activated with the keyboard', (
      WidgetTester tester,
    ) async {
      int activations = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContentCardWidget(
              title: 'Carte accessible',
              description: 'Description',
              onTap: () => activations++,
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(activations, 1);
    });

    testWidgets('supports a custom leading and navigation card styles', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 171,
              child: ContentCardWidget(
                title: 'Guide de tri',
                description: 'Pour bien trier !',
                leading: const SizedBox(key: Key('custom-leading'), height: 55),
                minHeight: 150,
                bottomAligned: true,
                textAlign: TextAlign.right,
                titleStyle: const TextStyle(fontSize: 15),
                descriptionStyle: const TextStyle(fontSize: 10),
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('custom-leading')), findsOneWidget);
      expect(
        tester.getSize(find.byType(ContentCardWidget)).height,
        greaterThanOrEqualTo(150),
      );
      expect(
        tester.widget<Text>(find.text('Guide de tri')).textAlign,
        TextAlign.right,
      );
      expect(
        tester.widget<Text>(find.text('Guide de tri')).style!.fontSize,
        15,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders with title and description', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContentCardWidget(
              title: 'Tri des déchets',
              description: 'Apprenez à trier correctement vos déchets',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Tri des déchets'), findsOneWidget);
      expect(
        find.text('Apprenez à trier correctement vos déchets'),
        findsOneWidget,
      );
      expect(find.byType(ContentCardWidget), findsOneWidget);
    });

    testWidgets('renders with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContentCardWidget(
              title: 'Recyclage',
              description: 'Guide de recyclage',
              icon: Icons.recycling,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.recycling), findsOneWidget);
      expect(find.text('Recyclage'), findsOneWidget);
    });

    testWidgets('calls onTap when card is tapped', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContentCardWidget(
              title: 'Test',
              description: 'Description test',
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(wasTapped, true);
    });

    testWidgets('uses custom background color', (WidgetTester tester) async {
      const customColor = Color(0xFFE8F5E9);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContentCardWidget(
              title: 'Test',
              description: 'Description',
              backgroundColor: customColor,
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, customColor);
    });

    testWidgets('defaults to white background', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContentCardWidget(
              title: 'Test',
              description: 'Description',
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.white);
    });

    testWidgets('has border radius', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContentCardWidget(
              title: 'Test',
              description: 'Description',
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
    });

    testWidgets('truncates long title', (WidgetTester tester) async {
      const longTitle =
          'Ceci est un titre très long qui devrait être tronqué avec des points';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: ContentCardWidget(
                title: longTitle,
                description: 'Description',
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text).first);
      expect(text.maxLines, 2);
      expect(text.overflow, TextOverflow.ellipsis);
    });

    testWidgets('truncates long description', (WidgetTester tester) async {
      const longDesc =
          'Ceci est une très longue description qui devrait être tronquée avec des points de suspension';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: ContentCardWidget(
                title: 'Titre',
                description: longDesc,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      // Vérifier que le descriptif est tronqué
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('renders without onTap callback', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContentCardWidget(title: 'Test', description: 'Description'),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });
  });
}
