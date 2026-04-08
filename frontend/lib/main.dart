import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_register_screen.dart';
import 'screens/signup_screen.dart';
import 'theme/app_theme.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkillHire',
      theme: AppTheme.light,
      initialRoute: SignupScreen.routeName,
      routes: {
        '/': (ctx) => const SignupScreen(),
        AdminLoginScreen.routeName: (ctx) => const AdminLoginScreen(),
        AdminRegisterScreen.routeName: (ctx) => const AdminRegisterScreen(),
        AdminDashboardScreen.routeName: (ctx) => const AdminDashboardScreen(),
        SignupScreen.routeName: (ctx) => const SignupScreen(),
      },
    );
  }
}
