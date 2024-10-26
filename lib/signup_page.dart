import 'package:flutter/material.dart';
import 'consts/common_consts.dart';
import 'handlers/handle_signup.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
  bool _showSpinner = false;

  final spinkit = SpinKitFadingCircle(color: Colors.white, size: 25);

  void _signup() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String passwordConf = _passwordConfController.text;
    final String username = _usernameController.text.trim();

    _signupStatus.value = '';

    setState(() { _showSpinner = true; });

    // Validate data for signup
    final signupValidator = ValidateSignup(username, email, password, passwordConf);
    var (bool isValid, String errorMsg) = signupValidator.isValidParams();
    if (!isValid) {
      _signupStatus.value = errorMsg;
      setState(() { _showSpinner = false; });
      return;
    }
    
    (isValid, errorMsg) = await signupValidator.userExists();
    if (!isValid) {
      _signupStatus.value = errorMsg;
      setState(() { _showSpinner = false; });
      return;
    }

    // At this point the validation was successful
    final signupInsert = InsertSignup(email, password, username);
    (isValid, errorMsg) = await signupInsert.insertToDB();
    if (!isValid) {
      _signupStatus.value = errorMsg;
      setState(() { _showSpinner = false; });
      return;
    }

    setState(() { _showSpinner = false; });

    // TODO: send email to user about successful signup (when we have a domain name)
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
              SizedBox(height: 20,),
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
              SizedBox(height: 20,),
              ValueListenableBuilder<String>(
                valueListenable: _signupStatus,
                builder: (BuildContext context, String value, Widget? child) {
                  return Text(value, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary));
                }
              ),
              SizedBox(height: 20,),
              Builder(builder: (context) => _showSpinner ? spinkit : Container()),
            ],
          ),
        ),
      ),
    );
  }
}