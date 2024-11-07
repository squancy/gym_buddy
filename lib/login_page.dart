import 'package:flutter/material.dart';
import 'package:moye/moye.dart';
import 'consts/common_consts.dart';
import 'forgot_password.dart';
import 'handlers/handle_login.dart';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moye/widgets/gradient_overlay.dart';
import 'utils/helpers.dart' as helpers;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final ValueNotifier<String> _loginStatus = ValueNotifier<String>("");


  Future<void> _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    _loginStatus.value = '';

    final loginValidator = CheckLogin(email, password);
    final (bool isValid, String errorMsg, String userID) = await loginValidator.validateLogin();
    if (!isValid) {
      setState(() { _loginStatus.value = errorMsg; });
      return;
    }

    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    await prefs.setBool('loggedIn', true);
    await prefs.setString('userID', userID);

    // Successful login
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
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(LoginConsts.appBarText),
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
                        LoginConsts.mainScreenText,
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
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                          child: SizedBox(
                            height: 45,
                            child: ProgressButton(
                              onPressed: _login,
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
                              child: Text(LoginConsts.appBarText),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                              );
                            },
                            child: Text(
                              'Forgot password',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary
                              )
                            )
                          ),
                        ),
                        ValueListenableBuilder<String>(
                          valueListenable: _loginStatus,
                          builder: (BuildContext context, String value, Widget? child) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                              child: Text(
                                value,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary
                                )
                              ),
                            );
                          }
                        ),
                      ],
                    )
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