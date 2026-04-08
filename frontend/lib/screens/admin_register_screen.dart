import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'admin_login_screen.dart';

class AdminRegisterScreen extends StatefulWidget {
  static const String routeName = '/admin/register';

  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final result = await ApiService.adminRegister(
      recruiterName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    setState(() => _loading = false);

    if (!mounted) return;

    final ok = result['success'] == true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']?.toString() ?? (ok ? 'Registered' : 'Registration failed')),
        backgroundColor: ok ? Colors.green : Colors.redAccent,
      ),
    );

    if (ok) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7F3EA), Color(0xFFE9ECF4), Color(0xFFF7F3EA)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  color: Colors.white,
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'SkillHire Admin',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.navy,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Create Admin Account',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.ink, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Recruiter Name'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Recruiter name is required' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'Email'),
                            validator: (v) => (v == null || !v.contains('@')) ? 'Valid email is required' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(labelText: 'Password'),
                            validator: (v) => (v == null || v.length < 8) ? 'Minimum 8 characters' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirmController,
                            obscureText: true,
                            decoration: const InputDecoration(labelText: 'Confirm Password'),
                            validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _register,
                              child: _loading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Text('Create Admin'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already have an account?', style: TextStyle(color: AppTheme.ink)),
                              TextButton(
                                onPressed: _loading
                                    ? null
                                    : () => Navigator.of(context).pushReplacementNamed(AdminLoginScreen.routeName),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}
