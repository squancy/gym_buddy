import 'package:flutter_test/flutter_test.dart';
import 'package:gym_buddy/login_page.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Login page UI testing', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    final welcomeBackTxt = find.text('Welcome back');
    expect(welcomeBackTxt, findsOneWidget);
    
    final loginBtn = find.widgetWithText(FilledButton, 'Log in');
    expect(loginBtn, findsOneWidget);

    final forgotPassBtn = find.widgetWithText(TextButton, 'Forgot password');
    expect(forgotPassBtn, findsOneWidget);

    List<Finder> fields = [];
    for (final labelName in ['Email', 'Password']) {
      final labelField = find.ancestor(
        of: find.text(labelName),
        matching: find.byType(TextField),
      );
      fields.add(labelField);
      expect(labelField, findsOneWidget);
    }
  });
}