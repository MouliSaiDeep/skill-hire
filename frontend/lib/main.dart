import 'package:flutter/material.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkillHire',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SignupScreen(), 
      routes: {
        AdminLoginScreen.routeName: (ctx) => const AdminLoginScreen(),
        AdminDashboardScreen.routeName: (ctx) => const AdminDashboardScreen(),
        SignupScreen.routeName: (ctx) => const SignupScreen(),
      },
    );
  }
}