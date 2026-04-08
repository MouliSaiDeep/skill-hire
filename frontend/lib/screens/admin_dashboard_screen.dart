import 'package:flutter/material.dart';
import '../models/candidate_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/candidate_card.dart';
import 'admin_login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  static const String routeName = '/admin/dashboard';

  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Candidate> _allCandidates = [];
  List<Candidate> _displayedCandidates = [];
  final Set<String> _selectedSkills = <String>{};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadCandidates() async {
    try {
      final candidates = await ApiService.fetchCandidates();
      if (!mounted) return;
      setState(() {
        _allCandidates = candidates;
        _applySkillFilter();
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

  void _toggleSkill(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
      _applySkillFilter();
    });
  }

  void _clearSkillFilter() {
    setState(() {
      _selectedSkills.clear();
      _applySkillFilter();
    });
  }

  void _applySkillFilter() {
    if (_selectedSkills.isEmpty) {
      _displayedCandidates = List.from(_allCandidates);
      return;
    }

    _displayedCandidates = _allCandidates.where((candidate) {
      final candidateSkills = candidate.skills
          .split(',')
          .map((s) => s.trim().toLowerCase())
          .where((s) => s.isNotEmpty)
          .toSet();

      return _selectedSkills.every((requiredSkill) =>
          candidateSkills.contains(requiredSkill.toLowerCase()));
    }).toList();
  }

  List<String> _availableSkills() {
    final skills = <String>{};
    for (final candidate in _allCandidates) {
      final tokens = candidate.skills
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty);
      skills.addAll(tokens);
    }
    final ordered = skills.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return ordered;
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
    final availableSkills = _availableSkills();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3EA),
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.tonalIcon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.navy.withValues(alpha: 0.08),
                foregroundColor: AppTheme.navy,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF8F5EE), Color(0xFFEFEDE7), Color(0xFFF7F3EA)],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE8E0CF)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.navy.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 980;

                        if (compact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildOverviewSection(selectedCount),
                              const SizedBox(height: 16),
                              const Divider(height: 1),
                              const SizedBox(height: 16),
                              _buildFilterSection(availableSkills),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: _buildOverviewSection(selectedCount),
                            ),
                            const SizedBox(width: 26),
                            Expanded(
                              flex: 6,
                              child: _buildFilterSection(availableSkills),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _displayedCandidates.isEmpty
                        ? Center(
                            child: Text(
                              'No candidates found for selected skills.',
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
                                  childAspectRatio: 0.8,
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
      width: 168,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5EE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6DCC8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.navy),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(int selectedCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Talent Overview',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.navy,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Live hiring insights and quick status snapshot.',
          style: TextStyle(color: AppTheme.ink),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _metricTile('Candidates', _allCandidates.length.toString()),
            _metricTile('Filtered', _displayedCandidates.length.toString()),
            _metricTile('Selected', selectedCount.toString()),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterSection(List<String> availableSkills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.tune_rounded, color: AppTheme.navy, size: 18),
            const SizedBox(width: 6),
            const Text(
              'Filter By Skills',
              style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.navy),
            ),
            const Spacer(),
            if (_selectedSkills.isNotEmpty)
              TextButton.icon(
                onPressed: _clearSkillFilter,
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableSkills.map((skill) {
            final selected = _selectedSkills.contains(skill);
            return FilterChip(
              selected: selected,
              label: Text(skill),
              showCheckmark: false,
              onSelected: (_) => _toggleSkill(skill),
              selectedColor: AppTheme.navy,
              backgroundColor: const Color(0xFFF8F4EB),
              side: BorderSide(
                color: selected ? AppTheme.navy : const Color(0xFFE0D7C3),
              ),
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppTheme.ink,
                fontWeight: FontWeight.w600,
              ),
            );
          }).toList(),
        ),
        if (availableSkills.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('No skills available yet.', style: TextStyle(color: Colors.black54)),
          ),
      ],
    );
  }
}
