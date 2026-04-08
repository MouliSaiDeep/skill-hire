import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/candidate_model.dart';
import '../theme/app_theme.dart';

class CandidateCard extends StatefulWidget {
  final Candidate candidate;
  final VoidCallback onSelectPressed;

  const CandidateCard({
    super.key,
    required this.candidate,
    required this.onSelectPressed,
  });

  @override
  State<CandidateCard> createState() => _CandidateCardState();
}

class _CandidateCardState extends State<CandidateCard> {
  bool _isHovered = false;

  Widget _buildFrontSide() {
    return Container(
      key: const ValueKey(true),
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15.0,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50.withValues(alpha: 0.5),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 98,
            height: 98,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE1D8C4), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.navy.withValues(alpha: 0.12),
                  blurRadius: 16.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: widget.candidate.photoUrl.isNotEmpty
                  ? Image.network(
                      widget.candidate.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.person, size: 48, color: Colors.grey.shade400);
                      },
                    )
                  : Icon(Icons.person, size: 48, color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.candidate.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 19.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.navy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Hover to view details",
              style: TextStyle(
                color: AppTheme.navy,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackSide() {
    return Container(
      key: const ValueKey(false),
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15.0,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppTheme.navy.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.candidate.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              letterSpacing: 0.5,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const Divider(height: 18, thickness: 1),
          
          _buildInfoRow(Icons.email_outlined, widget.candidate.email),
          const SizedBox(height: 8.0),
          _buildInfoRow(Icons.phone_outlined, widget.candidate.phone),
          const SizedBox(height: 8.0),
          _buildInfoRow(
              widget.candidate.gender.toLowerCase() == 'female' 
                  ? Icons.female 
                  : (widget.candidate.gender.toLowerCase() == 'male' ? Icons.male : Icons.person), 
              widget.candidate.gender),
              
          const Spacer(),
          const Text(
            "SKILLS",
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12.0),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: widget.candidate.skills.split(',').map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.navy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.navy.withValues(alpha: 0.2)),
                ),
                child: Text(
                  s.trim(),
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.navy,
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: Colors.blueAccent.shade400),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 13.5),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. The Flippable Card taking up most of the space
        Expanded(
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: _isHovered ? 180 : 0),
              builder: (context, double value, child) {
                bool isBack = value >= 90;
                double rotation = value * math.pi / 180;
                if (isBack) {
                  rotation = rotation - math.pi;
                }
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Add perspective
                    ..rotateY(rotation),
                  child: isBack ? _buildBackSide() : _buildFrontSide(),
                );
              },
            ),
          ),
        ),
        
        const SizedBox(height: 10.0),
        
        // 2. The Button below the card
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: widget.candidate.isSelected ? null : widget.onSelectPressed,
            icon: Icon(
              widget.candidate.isSelected ? Icons.check_circle : Icons.send_rounded,
              size: 20,
            ),
            label: Text(
              widget.candidate.isSelected ? 'Selected' : 'Send Mail',
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.candidate.isSelected ? Colors.green : AppTheme.navy,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.green.withValues(alpha: 0.7),
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0),
              ),
              elevation: widget.candidate.isSelected ? 0 : 4,
              shadowColor: AppTheme.navy.withValues(alpha: 0.35),
            ),
          ),
        ),
      ],
    );
  }
}