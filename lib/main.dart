import 'package:flutter/material.dart';
import 'theme.dart';

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
          const EdgeInsets.fromLTRB(40, 20, 40, 20)
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
  static const String _appTitle = 'Gym Buddy App';
  static const String _logInButtonTitle = 'Log In';
  static const String _signUpButtonTitle = 'Sign Up';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(_appTitle, style: TextStyle(fontSize: 42)),
            const SizedBox(height: 60),
            BigRedButton(displayText: _logInButtonTitle, onPressedFunc: () {}, fontSize: 22),
            const SizedBox(height: 30),
            BigRedButton(displayText: _signUpButtonTitle, onPressedFunc: () {}, fontSize: 22),
          ],
        ),
      ),
    );
  }
}
