import 'package:flutter/material.dart';
import 'theme.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'consts/common_consts.dart';
import 'forgot_password.dart';

void main() {
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
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                );
              }, child: Text(
                'Forgot password',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary
                )
              )
            )
          ],
        ),
      ),
    );
  }
}
