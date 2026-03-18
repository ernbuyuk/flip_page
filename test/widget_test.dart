import 'package:flutter_test/flutter_test.dart';

import 'package:flip_page/main.dart';

void main() {
  testWidgets('App acilisinda ana ekran gorunur', (WidgetTester tester) async {
    await tester.pumpWidget(FlipPageApp());
    await tester.pumpAndSettle();

    expect(find.text('FlipPage'), findsOneWidget);
    expect(find.text('Yeni Not'), findsOneWidget);
    expect(find.text('Notlarım'), findsOneWidget);
  });
}
