import 'package:gym_buddy/handlers/handle_login.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_buddy/login_page.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_buddy/utils/helpers.dart' as helpers;

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await helpers.firebaseInit(test: true);
  final FirebaseFirestore db = FirebaseFirestore.instance;

  testWidgets('Log in page testing with Firestore', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    final loginBtn = find.widgetWithText(FilledButton, 'Log in');
    List<Finder> fields = [];
    for (final labelName in ['Email', 'Password']) {
      final labelField = find.ancestor(
        of: find.text(labelName),
        matching: find.byType(TextField),
      );
      fields.add(labelField);
    }

    List<String> emails = [
      "thisuserdoesnotexists@example.com",
      "asd@test.com"
    ];

    List<String> passwords = [
      "incorrect password",
      "asdasd"
    ];

    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 2; j++) {
        await tester.enterText(fields[0], emails[i]);
        await tester.enterText(fields[1], passwords[j]);
        await tester.tap(loginBtn);
        await tester.pumpAndSettle(); 
        CheckLogin cp = CheckLogin(emails[i], passwords[j]);
        (bool, String, String) res = await cp.validateLogin();
        if (i == 1 && j == 1) {
          final user = (await db.collection('users').where('email', isEqualTo: emails[i]).get()).docs[0].data();
          expect(res, (true, '', user['id']));
          expect(find.byKey(Key('homepage')), findsOneWidget);
        } else {
          expect(res, (false, 'Your email or password is incorrect', ''));
          expect(find.text('Your email or password is incorrect'), findsOneWidget);
        }
      }
    }
  });
}