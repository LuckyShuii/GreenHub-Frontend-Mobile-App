import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_frontend/app/app.dart';

void main() {
  testWidgets('Landing screen displays figma copy text', (WidgetTester tester) async {
    await tester.pumpWidget(const GreenHubApp());

    expect(find.text('Green\'Hub'), findsOneWidget);
    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Inscription'), findsOneWidget);
  });
}
