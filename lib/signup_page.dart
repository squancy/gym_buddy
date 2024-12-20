import 'package:flutter/material.dart';
import 'consts/common_consts.dart';
import 'handlers/handle_signup.dart';
import 'home_page.dart';
import 'package:moye/moye.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moye/widgets/gradient_overlay.dart';
import 'utils/helpers.dart' as helpers;
import 'package:geolocator/geolocator.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _passwordConfFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();

  final ValueNotifier<String> _signupStatus = ValueNotifier<String>("");

  Future<void> _requestPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return;
    } 
  }

  Future<void> _signup() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String passwordConf = _passwordConfController.text;
    final String username = _usernameController.text.trim();

    _signupStatus.value = '';
    if (!GlobalConsts.TEST) {
      await _requestPosition();
    }

    // Validate data for signup
    final signupValidator = ValidateSignup(username, email, password, passwordConf);
    var (bool isValid, String errorMsg) = signupValidator.isValidParams();
    if (!isValid) {
      setState(() { _signupStatus.value = errorMsg; });
      return;
    }
 
    (isValid, errorMsg) = await signupValidator.userExists();
    if (!isValid) {
      setState(() { _signupStatus.value = errorMsg; });
      return;
    }

    // At this point the validation was successful
    final signupInsert = InsertSignup(email, password, username);
    String userID;
    (isValid, errorMsg, userID) = await signupInsert.insertToDB();
    if (!isValid) {
      setState(() { _signupStatus.value = errorMsg; });
      return;
    }

    // TODO: send email to user about successful signup (when we have a domain name)

    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    await prefs.setBool('loggedIn', true);
    await prefs.setString('userID', userID);

    // On successful sign up redirect user to the home page
    // Also delete every previous route so that he cannot go back with a right swipe
    setState(() {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
        (Route<dynamic> route) => false,
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfController.dispose();
    _usernameController.dispose();

    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordConfFocusNode.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                        child: Text(
                          SignupConsts.mainScreenText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ).withGradientOverlay(gradient: LinearGradient(colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.tertiary,
                          Theme.of(context).colorScheme.primary,
                        ])),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                        child: helpers.BlackTextfield(
                          context,
                          'Username',
                          _usernameController,
                          _usernameFocusNode,
                          isPassword: false,
                          isEmail: false
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                        child: helpers.BlackTextfield(
                          context,
                          'Email',
                          _emailController,
                          _emailFocusNode,
                          isPassword: false,
                          isEmail: true
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                        child: helpers.BlackTextfield(
                          context,
                          'Password',
                          _passwordController,
                          _passwordFocusNode,
                          isPassword: true,
                          isEmail: false
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                        child: helpers.BlackTextfield(
                          context,
                          'Confirm password',
                          _passwordConfController,
                          _passwordConfFocusNode,
                          isPassword: true,
                          isEmail: false
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 45,
                              child: helpers.ProgressBtn(
                                onPressedFn: _signup,
                                child: Text(SignupConsts.appBarText)
                              )
                            ),
                            ValueListenableBuilder<String>(
                              valueListenable: _signupStatus,
                              builder: (BuildContext context, String value, Widget? child) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
                                  child: Text(
                                    value,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface)
                                  ),
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}