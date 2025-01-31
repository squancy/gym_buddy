import 'package:flutter/material.dart';
import 'theme.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'consts/common_consts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/helpers.dart' as helpers;
import 'package:flutter_moving_background/enums/animation_types.dart';
import 'package:flutter_moving_background/flutter_moving_background.dart';
import 'package:moye/moye.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  // Firebase init START
  await helpers.firebaseInit(test: false);
  // Firebase init END
  SystemChrome.setPreferredOrientations([ // Lock the app to portrait mode
    DeviceOrientation.portraitUp,
  ]);

  runApp(const GymBuddyApp());
}



class GymBuddyApp extends StatelessWidget {
  const GymBuddyApp({super.key});
  static const ColorScheme gymBuddyColorScheme = GlobalThemeData.defaultColorScheme;

// Main app widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: HomeConsts.appTitle, // Gym buddy app  
      theme: ThemeData(
        // fontFamily: 'Rethink Sans',
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: Colors.blue.shade900
      ),
      home: const WelcomePage(),
    );
  }
}

class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    required this.displayText,
    required this.onPressedFunc,
    required this.fontSize,
  });

  final String displayText;
  final VoidCallback onPressedFunc;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressedFunc,
      style: ButtonStyle(
        padding: WidgetStateProperty.all<EdgeInsets>(
          const EdgeInsets.fromLTRB(30, 10, 30, 10),
        ),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.white24,
            width: 2,
            style: BorderStyle.solid
          ),
          borderRadius: BorderRadius.circular(50))
        ),
        backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surface),
        minimumSize: WidgetStateProperty.all(Size(150, 50))
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: fontSize,
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold
        )
      )
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
 /// Check if the user is logged in
  Future<bool> _loggedIn() async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    bool loggedIn = true;
    bool? fi = await prefs.getBool('loggedIn');
    if (fi == null || fi == false) {
      await prefs.setBool('loggedIn', false);
      loggedIn = false;
    }
    return loggedIn;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loggedIn(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && snapshot.data) {
          return HomePage();
        } else if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: GlobalConsts.spinkit
            )
          );
        } else {
          return Scaffold(
            // 4 moving circles on the screen
            body: MovingBackground(
              animationType: AnimationType.translation,
              backgroundColor: Colors.black,
              circles: [
                MovingCircle(color: Theme.of(context).colorScheme.tertiary),
                MovingCircle(color: Theme.of(context).colorScheme.tertiary),
                MovingCircle(color: Theme.of(context).colorScheme.primary),
                MovingCircle(color: Theme.of(context).colorScheme.primary),
              ],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [Text(
                      HomeConsts.appTitle, // Gym buddy app
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      )
                    ),
                    // Log in button
                    const SizedBox(height: 60),
                    MainButton(
                      displayText: HomeConsts.loginButtonTitle, // Log in
                      onPressedFunc: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()), // Navitage to login page
                        );
                      },
                      fontSize: 18,
                    ).withGlowContainer(
                      color: Colors.white24,
                      blurRadius: 20
                    ),
                    // Sign up button
                    const SizedBox(height: 30),
                    MainButton(
                      displayText: HomeConsts.signupButtonTitle, // Sign up
                      onPressedFunc: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupPage()), // Navigate to signup page
                        );
                      },
                      fontSize: 18,
                    ).withGlowContainer(
                      color: Colors.white24,
                      blurRadius: 20
                    )
                  ],
                ),
              ),
            ),
          );
        }
      }
    );
  }
}