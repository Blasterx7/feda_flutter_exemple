import 'package:flutter_test/flutter_test.dart';

import 'package:lab_app/main.dart';

void main() {
  testWidgets('ShoesHub smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('ShoesHub'), findsOneWidget);
    expect(find.textContaining('produit'), findsOneWidget);
  });
}
