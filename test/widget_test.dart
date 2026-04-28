import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  testWidgets('App renders the new layout with the UCL counter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Real Madrid App'), findsOneWidget);
    expect(find.text('What stadium is that?'), findsOneWidget);
    expect(find.text('Matches'), findsOneWidget);
    expect(find.text('Trophies'), findsOneWidget);
    expect(find.text('Players'), findsOneWidget);

    expect(find.text('UCL Throphy: 0'), findsOneWidget);
    expect(find.text('UCL Throphy: 1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('UCL Throphy: 0'), findsNothing);
    expect(find.text('UCL Throphy: 1'), findsOneWidget);
  });
}
