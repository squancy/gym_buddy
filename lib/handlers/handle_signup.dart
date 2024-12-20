import 'package:email_validator/email_validator.dart';
import '../consts/common_consts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io' show Platform;
import 'package:uuid/uuid.dart';
import '../utils/helpers.dart' as helpers;
import 'package:dbcrypt/dbcrypt.dart';

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
      return (false, 'Fill all fields');
    } else if (_username.length > ValidateSignupConsts.MAX_USERNAME_LEN) {
      return (false, 'Username is too long');
    } else if (!EmailValidator.validate(_email)) {
      return (false, 'Email is invalid');
    } else if (_password != _passwordConf) {
      return (false, 'Password fields do not match');
    } else if (_password.length < 6) {
      return (false, 'The length of your password must be at least 6');
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(_username)) {
      return (false, 'Username can only contain alphanumeric characters and _');
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
        return (false, 'This username is already taken');
      }

      final QuerySnapshot usersWithEmail = await users.where('email', isEqualTo: _email).get();
      if (usersWithEmail.docs.isNotEmpty) {
        return (false, 'This email address is already taken');
      }

      return (true, '');
    } catch(error) {
      print(error);
      return (false, 'An unknown error occurred');
    }
  }
}

/*
  Inserts information about the new user into the db
*/

class InsertSignup {
  InsertSignup(
    this._email,
    this._password,
    this._username
  );

  final String _email;
  final String _password;
  final String _username;
  final _dbcrypt = DBCrypt();

  String _getPlatform() {
    // Detect current platform
    String platform = 'unknown';
    if (Platform.isAndroid) {
      platform = 'Android';
    } else if (Platform.isIOS) {
      platform = 'iOS';
    }
    return platform;
  }

  Future<(String salt, String password)> _hashPassword() async {
    // Create a different salt for each user
    // After that, hash the password with the generated salt
    String salt = _dbcrypt.gensaltWithRounds(10);
    var pwh = _dbcrypt.hashpw(_password, salt);
    return (salt, pwh);
  }

  Future<(bool success, String errorMsg, String userID)> insertToDB() async {
    // Insert user into db
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final users = db.collection('users');
    final userSettings = db.collection('user_settings');

    final (String salt, String pwh) = await _hashPassword();
    final String platform = _getPlatform();
    final Position? geoloc = await helpers.getGeolocation();

    var uuid = Uuid();
    String userID = uuid.v4();
    final data = {
      'id': userID,
      'username': _username,
      'email': _email,
      'password': pwh,
      'salt': salt,
      'platform': platform,
      'geoloc': geoloc != null ? [geoloc.latitude, geoloc.longitude] : geoloc,
      'signup_date': FieldValue.serverTimestamp()
    };

    final dataProfile = {
      'display_username': _username,
      'bio': '',
      'profile_pic_path': '',
      'profile_pic_url': ''
    };

    // Insert user into db
    try {
      await users.doc(userID).set(data);
      await userSettings.doc(userID).set(dataProfile);
    } catch (e) {
      print(e);
      return (false, 'An unknown error occurred', '');
    }

    // Successful signup
    return (true, '', userID);
  }
}