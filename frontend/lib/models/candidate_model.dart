class Candidate {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String skills;
  final String photoUrl;
  final String gender;
  bool isSelected;

  Candidate({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.skills,
    required this.photoUrl,
    this.gender = 'Not Specified',
    this.isSelected = false,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      skills: json['skills']?.toString() ?? '',
      photoUrl: json['photoUrl']?.toString() ?? '',
      gender: json['gender']?.toString() ?? 'Not Specified',
      isSelected: json['isSelected'] == true,
    );
  }

}
