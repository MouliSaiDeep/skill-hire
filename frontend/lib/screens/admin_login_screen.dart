import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';

import '../services/api_service.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatelessWidget {
  static const String routeName = '/admin-login';

  const AdminLoginScreen({super.key});

  Future<String?> _authUser(LoginData data) async {
    final email = (data.name).trim();
    final result = await ApiService.adminLogin(
      email: email,
      password: data.password,
    );

    if (result['success'] == true) {
      return null;
    }
    return result['message']?.toString() ?? 'Invalid admin credentials';
  }

  Future<String?> _registerUser(SignupData data) async {
    final email = (data.name ?? '').trim();
    if (!email.contains('@')) {
      return 'Please enter a valid email for admin registration';
    }

    final recruiterName = email.split('@').first;
    final result = await ApiService.adminRegister(
      recruiterName: recruiterName,
      email: email,
      password: data.password ?? '',
    );

    if (result['success'] == true) {
      return null;
    }
    return result['message']?.toString() ?? 'Admin registration failed';
  }

  Future<String?> _recoverPassword(String _) async {
    return 'Password recovery is not enabled';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterLogin(
        title: 'SkillHire Admin',
        onLogin: _authUser,
        onSignup: _registerUser,
        onRecoverPassword: _recoverPassword,
        userType: LoginUserType.email,
        onSubmitAnimationCompleted: () {
          Navigator.of(context).pushReplacementNamed(AdminDashboardScreen.routeName);
        },
        theme: LoginTheme(
          primaryColor: const Color(0xFFF7F3EA),
          accentColor: const Color(0xFF0E1A2B),
          titleStyle: const TextStyle(
            color: Color(0xFF0E1A2B),
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 10,
            margin: const EdgeInsets.only(top: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          inputTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF8F5EE),
            prefixIconColor: const Color(0xFF0E1A2B),
            suffixIconColor: const Color(0xFF0E1A2B),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFC9A45B), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          buttonTheme: const LoginButtonTheme(
            backgroundColor: Color(0xFF0E1A2B),
            splashColor: Color(0xFFC9A45B),
          ),
          bodyStyle: const TextStyle(color: Color(0xFF1A2738)),
          textFieldStyle: const TextStyle(color: Color(0xFF1A2738)),
        ),
        messages: LoginMessages(
          userHint: 'Admin Email',
          loginButton: 'SIGN IN',
          signupButton: 'CREATE ADMIN',
          confirmPasswordHint: 'Confirm Password',
          recoverPasswordButton: 'RECOVER',
        ),
      ),
    );
  }
}