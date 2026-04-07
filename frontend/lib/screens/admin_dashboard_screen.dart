import 'package:flutter/material.dart';
import '../models/candidate_model.dart';
import '../services/api_service.dart';
import '../widgets/candidate_card.dart';
import 'admin_login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  static const String routeName = '/admin-dashboard';

  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
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
    try {
      final candidates = await ApiService.fetchCandidates();
      if (!mounted) return;
      setState(() {
        _allCandidates = candidates;
        _displayedCandidates = List.from(_allCandidates);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load candidates from backend'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _filterResults() {
    String query = _filterController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _displayedCandidates = List.from(_allCandidates);
      } else {
        _displayedCandidates = _allCandidates
            .where((c) => c.skills.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _markUserAsSelected(Candidate candidate) async {
    final result = await ApiService.selectCandidate(candidate.id);

    if (result['success'] == true) {
      setState(() {
        candidate.isSelected = true;
      });
    }

    if (!mounted) return;
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (result['warning'] ??
                    '${candidate.name} has been selected! An email is being sent via AWS SES.')
                .toString(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ?? 'Failed to select candidate',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AdminLoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 1. Skill Filter Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _filterController,
                    decoration: InputDecoration(
                      labelText: 'Search candidates by skill (e.g., Flutter)',
                      labelStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                      ),
                    ),
                  ),
                ),

                // 2. Candidate List
                Expanded(
                  child: _displayedCandidates.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_search_outlined, size: 60, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'No matching candidates found.',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = 1;
                            if (constraints.maxWidth >= 1200) {
                              crossAxisCount = 4;
                            } else if (constraints.maxWidth >= 900) {
                              crossAxisCount = 3;  // "three flippable cards per row for laptop screen width"
                            } else if (constraints.maxWidth >= 550) {
                              crossAxisCount = 2;
                            }

                            return GridView.builder(
                              padding: const EdgeInsets.all(24.0),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: 0.65, // Adjusts height vs width to make it vertically rectangular
                                crossAxisSpacing: 24.0,
                                mainAxisSpacing: 24.0,
                              ),
                              itemCount: _displayedCandidates.length,
                              itemBuilder: (context, index) {
                                final candidate = _displayedCandidates[index];
                                return CandidateCard(
                                  candidate: candidate,
                                  onSelectPressed: () => _markUserAsSelected(candidate),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
