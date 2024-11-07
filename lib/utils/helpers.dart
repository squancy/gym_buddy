import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

Future<String?> getUserID() async {
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();
  return prefs.getString('userID');
}

Widget blackTextfield(
  BuildContext context,
  String labelText,
  TextEditingController? controller,
  FocusNode? focusNode,
  {required bool isPassword, required bool isEmail}
  ) {
  return TextField(
    controller: controller,
    focusNode: focusNode,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
      labelText: labelText,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.secondary,
        fontWeight: FontWeight.w500
      ),
      floatingLabelStyle: TextStyle(
        color: Theme.of(context).colorScheme.primary
      ),
      fillColor: Colors.black,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
    onTapOutside: (event) {
      FocusManager.instance.primaryFocus?.unfocus();
    },
    obscureText: isPassword,
    keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
  );
}
