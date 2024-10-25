import 'package:flutter/material.dart';
import 'consts/common_consts.dart';
import 'forgot_password.dart';
import 'handlers/handle_login.dart';

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

  void _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    final loginValidator = CheckLogin(email, password);
    final (bool isValid, String errorMsg) = await loginValidator.validateLogin();
    if (!isValid) {
      _loginStatus.value = errorMsg;
      return;
    }

    // Successful login
    print('success');
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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                LoginConsts.mainScreenText,
                style: TextStyle(
                  fontSize: 42,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _login,
                child: const Text(LoginConsts.appBarText)),
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
              ),
              ValueListenableBuilder<String>(
                valueListenable: _loginStatus,
                builder: (BuildContext context, String value, Widget? child) {
                  return Text(value, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary));
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}