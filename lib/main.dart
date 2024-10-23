import 'package:flutter/material.dart';
import 'theme.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'consts/common_consts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GymBuddyApp());
}

class GymBuddyApp extends StatelessWidget {
  const GymBuddyApp({super.key});
  static const ColorScheme gymBuddyColorScheme = GlobalThemeData.defaultColorScheme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gym Buddy App',
      theme: ThemeData(
        fontFamily: 'Rethink Sans',
        useMaterial3: true,
        colorScheme: gymBuddyColorScheme
      ),
      home: const HomePage(),
    );
  }
}

class BigRedButton extends StatelessWidget {
  const BigRedButton({
    super.key,
    required this.displayText,
    required this.onPressedFunc,
    required this.fontSize,
  });

  final String displayText;
  final VoidCallback? onPressedFunc;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressedFunc,
      style: ButtonStyle(
        padding: WidgetStateProperty.all<EdgeInsets>(
          const EdgeInsets.fromLTRB(30, 10, 30, 10)
        )
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: fontSize
        )
      )
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(HomeConsts.appTitle, style: TextStyle(fontSize: 42)),
            const SizedBox(height: 60),
            BigRedButton(
              displayText: HomeConsts.loginButtonTitle,
              onPressedFunc: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              fontSize: 18,
            ),
            const SizedBox(height: 30),
            BigRedButton(
              displayText: HomeConsts.signupButtonTitle,
              onPressedFunc: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupPage()),
                );
              },
              fontSize: 18,
            ) 
          ],
        ),
      ),
    );
  }
}
