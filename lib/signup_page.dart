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
    await _requestPosition();

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
    var userID;
    (isValid, errorMsg, userID) = await signupInsert.insertToDB();
    if (!isValid) {
      setState(() { _signupStatus.value = errorMsg; });
      return;
    }

    // TODO: send email to user about successful signup (when we have a domain name)

    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    await prefs.setBool('loggedIn', true);
    await prefs.setString('userID', userID);

    // Redirect user to main page
    setState(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => HomePage()
        )
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
      appBar: AppBar(
        title: const Text(SignupConsts.appBarText),
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: LayoutBuilder(
          builder: (context, constraints) => ListView(
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
                        Colors.white,
                        Theme.of(context).colorScheme.primary,
                      ])),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                      child: helpers.blackTextfield(
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
                      child: helpers.blackTextfield(
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
                      child: helpers.blackTextfield(
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
                      child: helpers.blackTextfield(
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
                            child: ProgressButton(
                              onPressed: _signup,
                              loadingType: ProgressButtonLoadingType.replace,
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
                                foregroundColor: WidgetStateProperty.all(Colors.white),
                                textStyle: WidgetStatePropertyAll(
                                  TextStyle(
                                    fontWeight: FontWeight.bold
                                  )
                                )
                              ),
                              type: ProgressButtonType.filled,
                              child: Text(SignupConsts.appBarText),
                            ),
                          ),
                          ValueListenableBuilder<String>(
                            valueListenable: _signupStatus,
                            builder: (BuildContext context, String value, Widget? child) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
                                child: Text(
                                  value,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)
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
          )
        ),
      ),
    );
  }
}