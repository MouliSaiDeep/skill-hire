import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'admin_login_screen.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/signup';

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  XFile? _profileImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  final List<String> _availableSkills = [
    'Java', 'Python', 'Flutter', 'Spring Boot', 
    'React', 'Node.js', 'AWS', 'Docker', 
    'SQL', 'MongoDB'
  ];
  final Set<String> _selectedSkills = {};

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile picture'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one skill'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var result = await ApiService.signup(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      phone: _phoneController.text.trim(),
      skills: _selectedSkills.toList(),
      imageFile: _profileImage!,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
      );
      // Optional: Navigate to Admin login
      // Navigator.of(context).pushReplacementNamed(AdminLoginScreen.routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black87),
        validator: (val) => val == null || val.isEmpty ? 'Please enter $label' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.grey[200],
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Join SkillHire', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin Login',
            onPressed: () {
              Navigator.of(context).pushNamed(AdminLoginScreen.routeName);
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.blueAccent, width: 2),
                        image: _profileImage != null
                            ? DecorationImage(
                                image: kIsWeb 
                                  ? NetworkImage(_profileImage!.path) as ImageProvider
                                  : FileImage(io.File(_profileImage!.path)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _profileImage == null
                          ? const Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.blueAccent)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text('Profile Photo', style: TextStyle(color: Colors.black54)),
                ),
                const SizedBox(height: 25),

                _buildTextField(_nameController, 'Full Name', Icons.person_outline),
                _buildTextField(_emailController, 'Email Address', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                _buildTextField(_passwordController, 'Password', Icons.lock_outline, isPassword: true),
                _buildTextField(_phoneController, 'Phone Number', Icons.phone_outlined, keyboardType: TextInputType.phone),
                
                const SizedBox(height: 15),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Select Skills:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                ),
                
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _availableSkills.map((skill) {
                      final isSelected = _selectedSkills.contains(skill);
                      return FilterChip(
                        label: Text(skill),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedSkills.add(skill);
                            } else {
                              _selectedSkills.remove(skill);
                            }
                          });
                        },
                        selectedColor: Colors.blueAccent.withOpacity(0.2),
                        checkmarkColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? Colors.blueAccent : Colors.grey[400]!,
                          )
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 40),
                
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                    : ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'SIGN UP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                const SizedBox(height: 30),
              ],
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
    _phoneController.dispose();
    super.dispose();
  }
}
