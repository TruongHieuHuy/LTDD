// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truonghieuhuy/providers/theme_provider.dart';
import 'package:truonghieuhuy/providers/auth_provider.dart';
import 'package:truonghieuhuy/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Initialize providers for testing
    final themeProvider = ThemeProvider();
    await themeProvider.initialize();
    
    final authProvider = AuthProvider();
    await authProvider.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(SmartStudentApp(
      themeProvider: themeProvider,
      authProvider: authProvider,
    ));

    // Verify that the app initializes correctly
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
