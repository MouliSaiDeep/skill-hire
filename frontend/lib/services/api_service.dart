import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class ApiService {
  // Use 10.0.2.2 for Android emulator, localhost for iOS/Web.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api/auth';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api/auth';
    } else {
      return 'http://localhost:8080/api/auth';
    }
  }

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required List<String> skills,
    required XFile imageFile,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/signup'));

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
}
