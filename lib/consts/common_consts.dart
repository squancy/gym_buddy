import 'package:flutter/material.dart';

// Login page [login_page.dart]
class LoginConsts {
  static const String appBarText = 'Log in';
  static const String mainScreenText = 'Welcome back';
  static const String forgotPasswordText = 'Forgot password';
}

// Signup page [signup_page.dart]
class SignupConsts {
  static const String appBarText = 'Sign up';
  static const String mainScreenText = 'Create account';
  static const String usernameText = 'Username';
  static const String emailText = 'Email';
  static const String passwordText = 'Password';
  static const String passwordConfText = 'Confirm password';
}

// Home page [main.dart]
class HomeConsts {
  static const String appTitle = 'Gym Buddy App'; // TODO - Change the app title to something better
  static const String loginButtonTitle = 'Log in';
  static const String signupButtonTitle = 'Sign up';
}

// Forgot password [forgot_password.dart]
class ForgotPasswordConsts {
  static const String appBarText = 'Forgot password';
  static const String mainScreenText = 'New password';
  static const String infoText = 'We will send a temporary password to your email';
  static const String redBtnText = 'Send password';
}

class PostPageConsts {
  static const String errorMessageText =   'An unknown error occurred';
  static const String appBarText = 'Find a gym buddy';
  static const String textBarText = 'Looking for a buddy?';
  static const String dayTypeText = 'What are you going to do?';
  static const String gymTypeText = 'Which gym are you going to?';
  static const String timeTypeText = 'What time?';
  static const String photosUploadText = 'Upload photos';
  static const String postButtonText = 'Post';
}

// Signup page validation [validate_signup.dart]
class ValidateSignupConsts {
  static const int MAX_USERNAME_LEN = 100;
}

// Profile page [profile_page.dart]
class ProfileConsts {
  static const int MAX_BIO_LEN = 200;
  static const String defaultProfilePicPath = 'assets/default_profile_pic.png';
  static const int PAGINATION_NUM = 24;
  static const int profilePicSize = 200;
}

class GlobalConsts {
  static const spinkit = CircularProgressIndicator.adaptive();
  static const bool TEST = true;
}