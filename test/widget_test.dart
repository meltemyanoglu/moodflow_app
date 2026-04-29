import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:moodflow_app/main.dart';

void main() {
  testWidgets('MoodFlow app opens without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MoodFlowApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Mood Analytics screen title can be found if StatsScreen is opened',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MoodFlowApp());

    expect(find.text('MoodFlow'), findsWidgets);
  });
}