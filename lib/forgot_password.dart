import 'package:flutter/material.dart';
import 'consts/common_consts.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  void _sendPassword() {
    final String email = _emailController.text;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ForgotPasswordConsts.appBarText),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                ForgotPasswordConsts.mainScreenText,
                style: TextStyle(
                  fontSize: 28,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30,),
              Text(
                ForgotPasswordConsts.infoText,
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)
              ),
              const SizedBox(height: 30,),
              TextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _sendPassword,
                child: const Text(ForgotPasswordConsts.redBtnText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}