import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static const String _frontendHost =
      'frontend-route-23mh1a05l8-dev.apps.rm3.7wse.p1.openshiftapps.com';
  static const String _backendHost =
      'skill-hire-route-23mh1a05l8-dev.apps.rm3.7wse.p1.openshiftapps.com';
  static const String _backendOrigin = 'https://$_backendHost';

  static String get baseUrl {
    const defined = String.fromEnvironment('API_BASE_URL');
    if (defined.isNotEmpty) {
      return defined;
    }

    if (kIsWeb) {
      final current = Uri.base;
      if (current.host == _frontendHost) {
        return _backendOrigin;
      }
      return _backendOrigin;
    }

    return _backendOrigin;
  }

  static String get candidateBase => '$baseUrl/candidate';
  static String get adminBase => '$baseUrl/admin';

  static String get signup => '$candidateBase/apply';
  static String get adminLogin => '$adminBase/login';
  static String get adminRegister => '$adminBase/register';
  static String get candidates => '$adminBase/candidates';

  static String selectCandidate(String id) => '$adminBase/candidates/$id/select';
}
