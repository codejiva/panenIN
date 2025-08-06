// This is a basic Flutter widget test for PanenIn app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:PanenIn/main.dart';

void main() {
  testWidgets('App smoke test - should load without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for any async operations to complete (like auth initialization)
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that the app loads successfully
    // The app should show MaterialApp as the root widget
    expect(find.byType(MaterialApp), findsOneWidget);

    // Since the app starts with auth check or onboarding,
    // we verify that some content is displayed
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('App navigation test - onboarding elements', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for the app to settle
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Look for common text that might appear in onboarding or auth screens
    // You can customize these based on your actual app content
    final commonTexts = [
      'PanenIn',
      'Panen In',
      'Real-Time Monitoring',
      'Smarter Farming',
      'Welcome',
      'Initializing',
      'Loading'
    ];

    bool foundText = false;
    for (String text in commonTexts) {
      if (find.text(text).evaluate().isNotEmpty) {
        foundText = true;
        break;
      }
    }

    // At least one of the expected texts should be found
    expect(foundText, true, reason: 'Should find at least one expected text in the app');
  });
}