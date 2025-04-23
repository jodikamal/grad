import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graduation/main.dart'; // خليه حسب اسم مشروعك بالضبط

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // GlamzyApp
    await tester.pumpWidget(const GlamzyApp());

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
