import 'package:flutter/material.dart';
import '../models/candidate_model.dart';

class CandidateCard extends StatelessWidget {
  final Candidate candidate;
  final VoidCallback onSelectPressed;

  const CandidateCard({
    super.key,
    required this.candidate,
    required this.onSelectPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.all(8.0),
      color: candidate.isSelected ? Colors.green.withValues(alpha: 0.05) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            CircleAvatar(
              radius: 30.0,
              backgroundImage: NetworkImage(candidate.photoUrl),  
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidate.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                  Text(
                    candidate.email,
                    style: const TextStyle(color: Colors.grey, fontSize: 14.0),
                  ),
                  Text(
                    "Phone: ${candidate.phone}",
                    style: const TextStyle(fontSize: 14.0),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    "Skills: ${candidate.skills}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis, // Keep it clean
                    style: const TextStyle(fontSize: 13.0, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),

            Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                color: candidate.isSelected
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.blue.withValues(alpha: 0.1),
                border: Border.all(color: candidate.isSelected ? Colors.green : Colors.blue),
                borderRadius: BorderRadius.circular(10.0), // Match the sketch's rounded look
              ),
              child: IconButton(
                icon: Icon(
                  candidate.isSelected ? Icons.check_circle : Icons.person_add,
                  color: candidate.isSelected ? Colors.green : Colors.blue,
                ),
                onPressed: onSelectPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}