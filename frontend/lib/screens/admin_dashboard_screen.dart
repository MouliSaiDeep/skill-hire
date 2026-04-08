import 'package:flutter/material.dart';
import '../models/candidate_model.dart';
import '../services/api_service.dart';
import '../widgets/candidate_card.dart';
import 'admin_login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  static const String routeName = '/admin/dashboard';

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
    final query = _filterController.text.trim();
    final tokens = query
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (tokens.isEmpty) {
      setState(() {
        _displayedCandidates = List.from(_allCandidates);
      });
      return;
    }

    ApiService.fetchCandidatesBySkills(skills: tokens).then((candidates) {
      if (!mounted) return;
      setState(() {
        _displayedCandidates = candidates;
      });
    }).catchError((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to filter candidates by skills'),
          backgroundColor: Colors.redAccent,
        ),
      );
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
    final selectedCount = _allCandidates.where((c) => c.isSelected).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EA),
      appBar: AppBar(
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
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _metricTile('Candidates', _allCandidates.length.toString()),
                            _metricTile('Filtered', _displayedCandidates.length.toString()),
                            _metricTile('Selected', selectedCount.toString()),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _filterController,
                          decoration: InputDecoration(
                            labelText: 'Filter by skill words separated by comma (example: Flutter, AWS)',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _filterController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _filterController.clear();
                                      _filterResults();
                                    },
                                    icon: const Icon(Icons.close),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _displayedCandidates.isEmpty
                        ? Center(
                            child: Text(
                              'No candidates found for that exact skill set.',
                              style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, gridConstraints) {
                              int crossAxisCount = 1;
                              if (gridConstraints.maxWidth >= 1200) {
                                crossAxisCount = 4;
                              } else if (gridConstraints.maxWidth >= 900) {
                                crossAxisCount = 3;
                              } else if (gridConstraints.maxWidth >= 560) {
                                crossAxisCount = 2;
                              }

                              return GridView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 18,
                                  mainAxisSpacing: 18,
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
            ),
    );
  }

  Widget _metricTile(String title, String value) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5EE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6DCC8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
