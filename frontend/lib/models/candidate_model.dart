class Candidate {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String skills;
  final String photoUrl;
  bool isSelected;

  Candidate({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.skills,
    required this.photoUrl,
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
      isSelected: json['isSelected'] == true,
    );
  }

  // Mock data generator for testing
  static List<Candidate> getMockData() {
    return [
      Candidate(
        id: '1',
        name: 'Alice Johnson',
        email: 'alice.johnson@example.com',
        phone: '123-456-7890',
        skills: 'Flutter, Dart, Git, AWS',
        photoUrl:
            'https://cdn-icons-png.flaticon.com/512/3135/3135715.png', // Generic URL for testing
      ),
      Candidate(
        id: '2',
        name: 'Bob Smith',
        email: 'bob.smith@example.com',
        phone: '987-654-3210',
        skills: 'Java, Spring Boot, MySQL, Docker',
        photoUrl: 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
      ),
      Candidate(
        id: '3',
        name: 'Charlie Davis',
        email: 'charlie.d@example.com',
        phone: '555-123-4567',
        skills: 'Flutter, Firebase, AWS SES, CI/CD',
        photoUrl: 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
      ),
      Candidate(
        id: '4',
        name: 'Diana Evans',
        email: 'diana.e@example.com',
        phone: '555-987-6543',
        skills: 'Python, Django, AWS, OpenShift',
        photoUrl: 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
      ),
    ];
  }
}
