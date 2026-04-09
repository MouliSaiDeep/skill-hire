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
    final recruiterName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final result = await ApiService.adminRegister(
      recruiterName: recruiterName,
      email: email,
      password: password,
    );
    setState(() => _loading = false);

    if (!mounted) return;

    final ok = result['success'] == true;

    if (ok) {
      if (result['data'] != null && result['data']['otp_required'] == true) {
        _showOtpDialog(recruiterName, email, password);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered! Please login.')),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']?.toString() ?? 'Registration failed'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _showOtpDialog(String recruiterName, String email, String password) async {
    final otpController = TextEditingController();
    bool dialogLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Enter OTP'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('A 4-digit OTP has been sent to your email.'),
                const SizedBox(height: 16),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: dialogLoading ? null : () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: dialogLoading
                    ? null
                    : () async {
                        if (otpController.text.trim().isEmpty) return;
                        setStateDialog(() => dialogLoading = true);
                        final result = await ApiService.verifyAdminRegisterOtp(
                          recruiterName: recruiterName,
                          email: email,
                          password: password,
                          otp: otpController.text.trim(),
                        );
                        setStateDialog(() => dialogLoading = false);

                        if (!mounted) return;
                        if (result['success'] == true) {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Admin successfully registered. Please sign in!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.of(context).pushReplacementNamed(AdminLoginScreen.routeName);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message'] ?? 'Invalid OTP'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                child: dialogLoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Verify'),
              ),
            ],
          );
        });
      },
    );
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
                            validator: (v) => (v == null || !RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$').hasMatch(v)) ? 'Valid email is required' : null,
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
