import 'package:gym_buddy/handlers/handle_signup.dart';
import 'package:gym_buddy/consts/common_consts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_buddy/signup_page.dart';
import 'package:flutter/material.dart';

void main() {
  /// Sign up logic test START
  group('Test the validity of username, email and password fields on the sign up page', () {
    group('If any field is empty return false', () {
      List<dynamic> emptyTestcases = [
        ('', '', '', ''),
        ('testusername', '', '', ''),
        ('', 'testemail@test.com', '', ''),
        ('', '', 'password', ''),
        ('', '', '', 'password'),
        ('testusername', 'testemail@test.com', '', ''),
        ('testusername', '', 'password', ''),
        ('testusername', '', '', 'password'),
        ('', 'testemail@test.com', 'password', ''),
        ('', 'testemail@test.com', '', 'password'),
        ('', '', 'password', 'password'),
        ('testusername', 'testemail@test.com', 'password', ''),
        ('testusername', 'testemail@test.com', '', 'password'),
        ('testusername', '', 'password', 'password'),
        ('testusername', '', 'password', 'password'),
      ];

      for (final testcase in emptyTestcases) {
        test('Some of the fields are empty', () {
          final t = ValidateSignup(testcase.$1, testcase.$2, testcase.$3, testcase.$4);      
          final v = t.isValidParams();
          expect(v, (false, 'Fill all fields'));
        });
      }
    });
    test('Username is too long', () {
      final t = ValidateSignup('a' * (ValidateSignupConsts.MAX_USERNAME_LEN + 1), 'testemail@test.com', 'password', 'password');
      final v = t.isValidParams();
      expect(v, (false, 'Username is too long'));
    });

    List<dynamic> invalidEmails = [
      ('testusername', 'wrongemail', 'password', 'password'),
      ('testusername', 'wrongemail@', 'password', 'password'),
      ('testusername', '@wrongemail', 'password', 'password'),
      ('testusername', 'wron@gemail', 'password', 'password')
    ];

    for (final testcase in invalidEmails) {
      test('Invalid emails', () {
        final t = ValidateSignup(testcase.$1, testcase.$2, testcase.$3, testcase.$4);      
        final v = t.isValidParams();
        expect(v, (false, 'Email is invalid'));
      });
    }

    test('Password length < 6', () {
      final t = ValidateSignup('testusername', 'testemail@test.com', 'asd', 'asd');      
      final v = t.isValidParams();
      expect(v, (false, 'The length of your password must be at least 6'));
    });

    test('Username contains non-alphanumeric characters besides _', () {
      final t = ValidateSignup('hey(=)', 'testemail@test.com', 'password', 'password');      
      final v = t.isValidParams();
      expect(v, (false, 'Username can only contain alphanumeric characters and _'));
    });

    test('Password fields do not match', () {
      final t = ValidateSignup('testusername', 'testemail@test.com', 'password1', 'password2');      
      final v = t.isValidParams();
      expect(v, (false, 'Password fields do not match'));
    });

    test('All parameters are valid', () {
      final t = ValidateSignup('testusername', 'testemail@test.com', 'password', 'password');      
      final v = t.isValidParams();
      expect(v, (true, ''));
    });
  });
  /// Sign up logic test END
  
  /// Sign up UI test START
  testWidgets('Sign up page UI testing', (tester) async {
    await tester.pumpWidget(MaterialApp(home: SignupPage()));

    final createAccountTxt = find.text('Create account');
    final signupBtn = find.widgetWithText(FilledButton, 'Sign up');

    List<Finder> fields = [];
    for (final labelName in ['Username', 'Email', 'Password', 'Confirm password']) {
      final labelField = find.ancestor(
        of: find.text(labelName),
        matching: find.byType(TextField),
      );
      fields.add(labelField);
      expect(labelField, findsOneWidget);
    }

    expect(createAccountTxt, findsOneWidget);
    expect(signupBtn, findsOneWidget);

    await tester.tap(signupBtn);
    await tester.pumpAndSettle();
    final msgFill = find.text('Fill all fields');
    expect(msgFill, findsOneWidget);

    await tester.enterText(fields[0], "a" * 101);
    await tester.enterText(fields[1], "a");
    await tester.enterText(fields[2], "a");
    await tester.enterText(fields[3], "a");
    await tester.tap(signupBtn);
    await tester.pumpAndSettle();
    final msgTooLong = find.text('Username is too long');
    expect(msgTooLong, findsOneWidget);

    await tester.enterText(fields[0], "testusername");
    await tester.enterText(fields[1], "invalid email");
    await tester.tap(signupBtn);
    await tester.pumpAndSettle();
    final msgInvalidEmail = find.text('Email is invalid');
    expect(msgInvalidEmail, findsOneWidget);

    await tester.enterText(fields[1], "valid@email.com");
    await tester.enterText(fields[2], "short");
    await tester.enterText(fields[3], "short");
    await tester.tap(signupBtn);
    await tester.pumpAndSettle();
    final msgShortPwd = find.text('The length of your password must be at least 6');
    expect(msgShortPwd, findsOneWidget);

    await tester.enterText(fields[2], "password1");
    await tester.enterText(fields[3], "password2");
    await tester.tap(signupBtn);
    await tester.pumpAndSettle();
    final msgMismatchPwd = find.text('Password fields do not match');
    expect(msgMismatchPwd, findsOneWidget);

    await tester.enterText(fields[0], "invalid_username!");
    await tester.enterText(fields[2], "password");
    await tester.enterText(fields[3], "password");
    await tester.tap(signupBtn);
    await tester.pumpAndSettle();
    final msgInvalidUname = find.text('Username can only contain alphanumeric characters and _');
    expect(msgInvalidUname, findsOneWidget);
  });
  /// Sign up UI test END
}