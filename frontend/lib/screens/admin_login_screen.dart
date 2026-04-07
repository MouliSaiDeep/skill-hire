import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'admin_dashboard_screen.dart';
import '../services/api_service.dart';

class AdminLoginScreen extends StatelessWidget {
  static const String routeName = '/admin-login';

  const AdminLoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) async {
    await Future.delayed(loginTime);
    final result = await ApiService.adminLogin(email: data.name, password: data.password);

    if (result['success'] == true) {
      return null;
    }
    return result['message']?.toString() ?? 'Invalid Admin Credentials';
  }

  Future<String?> _recoverPassword(String name) async {
    // Optional: Logic for password recovery
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterLogin(
        title: 'Admin Login',
      onLogin: _authUser,
      onRecoverPassword: _recoverPassword,
      onSignup: null, 
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacementNamed(AdminDashboardScreen.routeName);
      },
      messages: LoginMessages(
        userHint: 'Admin Email',
        passwordHint: 'Password',
        confirmPasswordHint: 'Confirm',
        loginButton: 'LOG IN',
      ),
      theme: LoginTheme(
  primaryColor: Colors.white, 
  accentColor: Colors.blue,  
  
  // 1. Fix the Title (ADMIN PORTAL) visibility
  titleStyle: const TextStyle(
    color: Colors.blueAccent,
    fontWeight: FontWeight.bold,
    letterSpacing: 4,
  ),

  // 2. Fix the Card and Input Field visibility
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 5,
    margin: const EdgeInsets.only(top: 15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  
  // 3. Fix the icons and input text colors
  inputTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[200], // Light grey background for the input bars
    prefixIconColor: Colors.blueAccent, // This makes your icons visible
    suffixIconColor: Colors.blueAccent, // This makes the password "eye" visible
    labelStyle: const TextStyle(color: Colors.black87),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(10),
    ),
  ),

  // 4. Style the Login Button
  buttonTheme: const LoginButtonTheme(
    backgroundColor: Colors.blueAccent,
    highlightColor: Colors.blue,
  ),
  
),
    ),
  );
}
}
