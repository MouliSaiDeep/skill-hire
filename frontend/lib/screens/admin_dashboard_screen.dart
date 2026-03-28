import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For logout persistence
import '../models/candidate_model.dart';
import '../widgets/candidate_card.dart';
import 'admin_login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  static const String routeName = '/admin-dashboard';

  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _filterController = TextEditingController();
  List<Candidate> _allCandidates = [];
  List<Candidate> _displayedCandidates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
    _filterController.addListener(_filterResults);
  }

  @override
  void dispose() {
    _filterController.removeListener(_filterResults);
    _filterController.dispose();
    super.dispose();
  }

  Future<void> _loadCandidates() async {

    await Future.delayed(const Duration(seconds: 2));

    _allCandidates = Candidate.getMockData();

    setState(() {
      _displayedCandidates = List.from(_allCandidates);
      _isLoading = false;
    });
  }

  void _filterResults() {
    String query = _filterController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _displayedCandidates = List.from(_allCandidates);
      } else {
        _displayedCandidates = _allCandidates.where((c) => c.skills.toLowerCase().contains(query)).toList();
      }
    });
  }

  Future<void> _markUserAsSelected(Candidate candidate) async {
  
    setState(() {
      candidate.isSelected = !candidate.isSelected;
    });

    if (!mounted) return;
    if (candidate.isSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${candidate.name} has been selected! An email is being sent via AWS SES.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('User deselected.')),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AdminLoginScreen.routeName);
  }

  @override
  Widget build(BuildContext Context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(Context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 1. Skill Filter Box
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _filterController,
                    decoration: InputDecoration(
                      labelText: 'Filter by Skill (e.g., Flutter)',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                ),

                // 2. Candidate List (ListView of reusable custom Cards)
                Expanded(
                  child: _displayedCandidates.isEmpty
                      ? const Center(child: Text('No matching candidates found.'))
                      : ListView.builder(
                          itemCount: _displayedCandidates.length,
                          itemBuilder: (context, index) {
                            final candidate = _displayedCandidates[index];
                            return CandidateCard(
                              candidate: candidate,
                              // Connect card action to logic
                              onSelectPressed: () => _markUserAsSelected(candidate),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}