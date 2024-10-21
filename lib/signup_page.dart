import 'package:flutter/material.dart';
import 'consts/common_consts.dart';

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

  void _signup() {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String passwordConf = _passwordConfController.text;
    final String username = _usernameController.text;

    print('Email: $email, Password: $password');
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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                SignupConsts.mainScreenText,
                style: TextStyle(
                  fontSize: 28,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                controller: _usernameController,
                focusNode: _usernameFocusNode,
                decoration: const InputDecoration(labelText: 'Username'),
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
              TextField(
                controller: _passwordConfController,
                focusNode: _passwordConfFocusNode,
                decoration: const InputDecoration(labelText: 'Confirm password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _signup,
                child: const Text(SignupConsts.appBarText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}