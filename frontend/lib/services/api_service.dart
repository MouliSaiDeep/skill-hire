import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/candidate_model.dart';
import 'api_endpoints.dart';

class ApiService {
  static Map<String, dynamic> _decodeObjectOrEmpty(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Non-JSON responses (like HTML error pages) should not crash callers.
    }

    return <String, dynamic>{};
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

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

      final Map<String, dynamic> decoded = _decodeObjectOrEmpty(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded['success'] == true && decoded['data'] != null) {
          final token = decoded['data']['token'];
          if (token != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('jwt_token', token);
          }
        } else if (decoded['token'] != null) {
          // the backend returned token at the root, or structured different.
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', decoded['token']);
        }
        return {'success': true, 'message': 'Login successful', 'data': decoded};
      }

      final fallback = response.statusCode == 404
          ? 'Backend endpoint not found. Check API base URL and backend route mapping.'
          : 'Invalid admin credentials';

      return {
        'success': false,
        'message': decoded['message']?.toString() ?? fallback,
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

      final Map<String, dynamic> decoded = _decodeObjectOrEmpty(response.body);

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

    final headers = await getAuthHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 401) {
      throw Exception('401');
    }

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
      final headers = await getAuthHeaders();
      final response = await http.post(
        Uri.parse(ApiEndpoints.selectCandidate(candidateId)),
        headers: headers,
      );
      final Map<String, dynamic> decoded = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, ...decoded};
      }

      if (response.statusCode == 401) {
        return {'success': false, 'statusCode': 401, 'message': 'Unauthorized'};
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
