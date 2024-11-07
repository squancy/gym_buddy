import 'package:flutter/material.dart';

// Login page [login_page.dart]
class LoginConsts {
  static const String appBarText = 'Log in';
  static const String mainScreenText = 'Welcome back';
}

// Signup page [signup_page.dart]
class SignupConsts {
  static const String appBarText = 'Sign up';
  static const String mainScreenText = 'Create account';
}

// Home page [main.dart]
class HomeConsts {
  static const String appTitle = 'Gym Buddy App';
  static const String loginButtonTitle = 'Log in';
  static const String signupButtonTitle = 'Sign up';
}

// Forgot password [forgot_password.dart]
class ForgotPasswordConsts {
  static const String appBarText = 'Forgot password';
  static const String mainScreenText = 'New password';
  static const String infoText = 'We will send a temprary password to your email';
  static const String redBtnText = 'Send password';
}

// Signup page validation [validate_signup.dart]
class ValidateSignupConsts {
  static const int MAX_USERNAME_LEN = 100;
}

// Profile page [profile_page.dart]
class ProfileConsts {
  static const int MAX_BIO_LEN = 200;
  static const String defaultProfilePicPath = 'assets/default_profile_pic.png';
}

class GlobalConsts {
  static const spinkit = CircularProgressIndicator.adaptive();
}