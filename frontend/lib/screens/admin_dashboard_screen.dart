import 'package:flutter/material.dart';
// For logout persistence
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
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _filterController,
                    decoration: InputDecoration(
                      labelText: 'Filter by Skill (e.g., Flutter)',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),

                // 2. Candidate List (ListView of reusable custom Cards)
                Expanded(
                  child: _displayedCandidates.isEmpty
                      ? const Center(
                          child: Text('No matching candidates found.'),
                        )
                      : ListView.builder(
                          itemCount: _displayedCandidates.length,
                          itemBuilder: (context, index) {
                            final candidate = _displayedCandidates[index];
                            return CandidateCard(
                              candidate: candidate,
                              // Connect card action to logic
                              onSelectPressed: () =>
                                  _markUserAsSelected(candidate),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
