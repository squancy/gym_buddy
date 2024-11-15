import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dbcrypt/dbcrypt.dart';

class CheckLogin {
  CheckLogin(
    this._email,
    this._password
  );

  final String _email;
  final String _password;

  Future<QuerySnapshot> _getUserWithEmail(users) async {
    return await users.where('email', isEqualTo: _email).get();
  }

  Future<bool> _isPasswordValid(user) async {
    String passwordDB = user['password'];
    var bcrypt = DBCrypt();

    // Verify if the provided password matches the stored hash
    return bcrypt.checkpw(_password, passwordDB);
  }

  Future<(bool success, String errorMsg, String userID)> validateLogin() async {
    // Fetch user with the given email, if exists
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final users = db.collection('users');

    final QuerySnapshot userWithEmail = await _getUserWithEmail(users); 
    if (userWithEmail.docs.isEmpty) {
      return (false, 'Your email or password is incorrect', '');
    }

    var user = userWithEmail.docs[0].data() as Map<String, dynamic>;
    bool valid = await _isPasswordValid(user);
    return valid ? (true, '', user['id'] as String) : (false, 'Your email or password is incorrect', '');
  }
}
