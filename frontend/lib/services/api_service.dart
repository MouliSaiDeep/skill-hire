import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import '../models/candidate_model.dart';
import 'api_endpoints.dart';

class ApiService {
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String gender,
    required String phone,
    required List<String> skills,
    required XFile imageFile,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(ApiEndpoints.signup));

      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['gender'] = gender;
      request.fields['phone'] = phone;
      // Spring's @RequestParam List<String> handles comma separated values cleanly.
      request.fields['skills'] = skills.join(',');

      var bytes = await imageFile.readAsBytes();
      
      var multipartFile = http.MultipartFile.fromBytes(
        'pic',
        bytes,
        filename: imageFile.name,
      );
      request.files.add(multipartFile);

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'message': 'Successfully signed up!'};
      } else {
        String msg = "Signup failed";
        try {
           var decoded = jsonDecode(responseData);
           if (decoded['message'] != null) {
              msg = decoded['message'];
           }
        } catch (_) {
           msg = responseData.isNotEmpty ? responseData : "Unknown error";
        }
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> adminLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.adminLogin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final Map<String, dynamic> decoded = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'message': 'Login successful', 'data': decoded};
      }

      return {
        'success': false,
        'message': decoded['message']?.toString() ?? 'Invalid Admin Credentials'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> adminRegister({
    required String recruiterName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.adminRegister),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'recruiterName': recruiterName,
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> decoded = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'message': 'Admin registered successfully', 'data': decoded};
      }

      return {
        'success': false,
        'message': decoded['message']?.toString() ?? 'Admin registration failed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<List<Candidate>> fetchCandidates({String? skill}) async {
    return fetchCandidatesBySkills(
      skills: (skill != null && skill.trim().isNotEmpty) ? [skill.trim()] : const [],
    );
  }

  static Future<List<Candidate>> fetchCandidatesBySkills({required List<String> skills}) async {
    final normalized = skills.where((s) => s.trim().isNotEmpty).map((s) => s.trim()).toList();

    Uri uri;
    if (normalized.isEmpty) {
      uri = Uri.parse(ApiEndpoints.candidates);
    } else if (normalized.length == 1) {
      uri = Uri.parse('${ApiEndpoints.candidates}?skill=${Uri.encodeQueryComponent(normalized.first)}');
    } else {
      final query = normalized.map((s) => 'skills=${Uri.encodeQueryComponent(s)}').join('&');
      uri = Uri.parse('${ApiEndpoints.candidates}?$query');
    }

    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load candidates');
    }

    final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Candidate.fromJson)
        .toList();
  }

  static Future<Map<String, dynamic>> selectCandidate(String candidateId) async {
    try {
      final response = await http.post(Uri.parse(ApiEndpoints.selectCandidate(candidateId)));
      final Map<String, dynamic> decoded = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, ...decoded};
      }

      return {
        'success': false,
        'message': decoded['message']?.toString() ?? 'Failed to update candidate'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
