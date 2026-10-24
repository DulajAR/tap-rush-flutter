
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap_rush/main.dart';

void main() {
  testWidgets('Tap Rush application loads successfully', (tester) async {
    await tester.pumpWidget(const TapRushApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
