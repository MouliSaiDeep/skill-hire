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
  final _phoneController = TextEditingController();

  XFile? _profileImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  String _selectedGender = '';
  final Set<String> _selectedSkills = {};

  final List<String> _availableSkills = const [
    'Java',
    'Python',
    'Flutter',
    'Spring Boot',
    'React',
    'Node.js',
    'AWS',
    'Docker',
    'SQL',
    'MongoDB',
    'Jenkins',
    'Ansible',
    'OS',
    'DBMS',
    'C',
    'Selenium',
  ];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profileImage = image);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_profileImage == null) {
      _showError('Please select a profile picture');
      return;
    }
    if (_selectedGender.isEmpty) {
      _showError('Please select your gender');
      return;
    }
    if (_selectedSkills.isEmpty) {
      _showError('Please select at least one skill');
      return;
    }

    setState(() => _isLoading = true);
    final result = await ApiService.signup(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      gender: _selectedGender,
      phone: _phoneController.text.trim(),
      skills: _selectedSkills.toList(),
      imageFile: _profileImage!,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']?.toString() ?? 'Request finished'),
        backgroundColor: result['success'] == true ? Colors.green : Colors.redAccent,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter $label' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _genderChip(String value, IconData icon) {
    final selected = _selectedGender == value;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: selected ? Colors.white : Colors.black54),
          const SizedBox(width: 6),
          Text(value),
        ],
      ),
      selected: selected,
      onSelected: (_) => setState(() => _selectedGender = value),
      selectedColor: const Color(0xFF0E1A2B),
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
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
            colors: [Color(0xFFF6EFE3), Color(0xFFE6EBF6), Color(0xFFF6EFE3)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SkillHire Candidate Application',
                                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(height: 8),
                                    Text('A polished gateway to your next engineering opportunity.'),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => Navigator.of(context).pushNamed(AdminLoginScreen.routeName),
                                icon: const Icon(Icons.admin_panel_settings_outlined),
                                label: const Text('Admin Portal'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final compact = constraints.maxWidth < 760;
                              if (compact) {
                                return Column(
                                  children: [
                                    _photoPicker(),
                                    const SizedBox(height: 16),
                                    _detailsSection(),
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _photoPicker(),
                                  const SizedBox(width: 20),
                                  Expanded(child: _detailsSection()),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              _genderChip('Male', Icons.male),
                              _genderChip('Female', Icons.female),
                              _genderChip('Other', Icons.transgender),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const Text('Core Skills', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableSkills.map((skill) {
                              final selected = _selectedSkills.contains(skill);
                              return FilterChip(
                                selected: selected,
                                label: Text(skill),
                                onSelected: (on) {
                                  setState(() {
                                    if (on) {
                                      _selectedSkills.add(skill);
                                    } else {
                                      _selectedSkills.remove(skill);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              child: _isLoading
                                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Text('Submit Application'),
                            ),
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

  Widget _photoPicker() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 190,
            height: 230,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFC9A45B), width: 1.8),
              color: Colors.white,
              image: _profileImage != null
                  ? DecorationImage(
                      image: kIsWeb ? NetworkImage(_profileImage!.path) as ImageProvider : FileImage(io.File(_profileImage!.path)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _profileImage == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 42),
                      SizedBox(height: 10),
                      Text('Upload Portrait', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        const Text('Passport-style photo preferred'),
      ],
    );
  }

  Widget _detailsSection() {
    return Column(
      children: [
        _textField(_nameController, 'Full Name', Icons.badge_outlined),
        const SizedBox(height: 12),
        _textField(
          _emailController,
          'Email Address',
          Icons.alternate_email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _textField(
          _phoneController,
          'Phone Number',
          Icons.phone_android,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}