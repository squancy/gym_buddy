import 'package:flutter/material.dart';
import 'consts/common_consts.dart';
import 'utils/helpers.dart' as helpers;
import 'package:moye/moye.dart';
import 'package:moye/widgets/gradient_overlay.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  Future<void> _sendPassword() async {
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                child: Text(
                  ForgotPasswordConsts.mainScreenText,
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
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                  ForgotPasswordConsts.infoText,
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                ),
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
                child: SizedBox(
                  height: 45,
                  child: ProgressButton(
                    onPressed: _sendPassword,
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
                    child: Text(ForgotPasswordConsts.redBtnText),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}