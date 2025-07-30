import 'package:flutter/material.dart';
import 'lib/screens/ingredient_search_screen.dart';
import 'lib/screens/signup_screen.dart';
import 'lib/screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _accessToken;
  bool _showSignup = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _accessToken == null
          ? (_showSignup
          ? SignupScreen(onSignupSuccess: () {
        setState(() => _showSignup = false);
      })
          : LoginScreen(
        onLoginSuccess: (token) {
          setState(() => _accessToken = token);
        },
        onGoToSignup: () {
          setState(() => _showSignup = true);
        },
      ))
          : IngredientSearchScreen(accessToken: _accessToken!), // 로그인 성공시 검색화면으로!
    );
  }
}
