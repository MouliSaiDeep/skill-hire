import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import '../models/candidate_model.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator, localhost for iOS/Web.
  static String get _apiHost {
    if (kIsWeb) {
      return 'http://localhost:8080';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    } else {
      return 'http://localhost:8080';
    }
  }

  static String get _authBaseUrl => '$_apiHost/api/auth';
  static String get _adminBaseUrl => '$_apiHost/api/admin';

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required List<String> skills,
    required XFile imageFile,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_authBaseUrl/signup'));

      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
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
        Uri.parse('$_adminBaseUrl/login'),
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

  static Future<List<Candidate>> fetchCandidates({String? skill}) async {
    final query = (skill != null && skill.trim().isNotEmpty)
        ? '?skill=${Uri.encodeQueryComponent(skill.trim())}'
        : '';
    final uri = Uri.parse('$_adminBaseUrl/candidates$query');
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
      final response = await http.post(Uri.parse('$_adminBaseUrl/candidates/$candidateId/select'));
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
