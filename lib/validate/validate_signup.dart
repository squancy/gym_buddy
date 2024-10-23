import 'package:email_validator/email_validator.dart';
import '../consts/common_consts.dart';
import '../firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/*
  Validates parameters used during the sign up process
*/

class ValidateSignup {
  ValidateSignup(
    this._username,
    this._email,
    this._password,
    this._passwordConf,
  );

  final String _username;
  final String _email;
  final String _password;
  final String _passwordConf;

  (bool isValid, String errorMsg) isValidParams() {
    if (_username.isEmpty || _email.isEmpty || _password.isEmpty || _passwordConf.isEmpty) {
      return (false, 'Please fill all fields');
    } else if (_username.length > ValidateSignupConsts.MAX_USERNAME_LEN) {
      return (false, 'Username is too long. It cannot be more than 100 characters.');
    } else if (!EmailValidator.validate(_email)) {
      return (false, 'Email is invalid.');
    } else if (_password != _passwordConf) {
      return (false, 'The password fields do not match.');
    } else if (_password.length < 6) {
      return (false, 'The length of your password must be at least 6.');
    }
    return (true, '');
  }

  // Make sure username and email are unique
  Future<(bool isValid, String errorMsg)> userExists() async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final users = db.collection('users');
      final QuerySnapshot usersWithUsername = await users.where('username', isEqualTo: _username).get();
      if (usersWithUsername.docs.isNotEmpty) {
        return (false, 'This username is already taken.');
      }

      final QuerySnapshot allUsers = await users.get();
      for (var doc in allUsers.docs) {
        final Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        if (userData['email'] == _email) {
          return (false, 'This email address is already taken.');
        }
      }

      return (true, '');
    } catch(error) {
      return (false, 'An unknown error occurred.');
    }
  }
}