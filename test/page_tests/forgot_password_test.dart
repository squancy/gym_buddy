import 'package:flutter_test/flutter_test.dart';
import 'package:gym_buddy/forgot_password.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Forgot password UI testing', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ForgotPasswordPage()));
    final newPwdTxt = find.text('New password');
    expect(newPwdTxt, findsOneWidget);

    final infoTxt = find.text('We will send a temporary password to your email');
    expect(infoTxt, findsOneWidget);

    final sendPwdBtn = find.widgetWithText(FilledButton, 'Send password');
    expect(sendPwdBtn, findsOneWidget);

    final field = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextField),
    );

    expect(field, findsOneWidget);
  });
}