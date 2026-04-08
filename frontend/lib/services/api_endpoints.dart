import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static const String _defaultPort = '8080';
  static const String _frontendRouteToken = 'frontend-route';
  static const String _backendRouteToken = 'skill-hire-route';

  static String get baseUrl {
    const defined = String.fromEnvironment('API_BASE_URL');
    if (defined.isNotEmpty) {
      return defined;
    }

    if (kIsWeb) {
      if (kReleaseMode) {
        final current = Uri.base;
        final backendHost = current.host.replaceFirst(_frontendRouteToken, _backendRouteToken);

        if (backendHost != current.host) {
          return '${current.scheme}://$backendHost';
        }

        return current.origin;
      }

      return 'http://localhost:$_defaultPort';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$_defaultPort';
    }

    return 'http://localhost:$_defaultPort';
  }

  static String get authBase => '$baseUrl/api/auth';
  static String get adminBase => '$baseUrl/api/admin';

  static String get signup => '$authBase/signup';
  static String get adminLogin => '$adminBase/login';
  static String get adminRegister => '$adminBase/register';
  static String get candidates => '$adminBase/candidates';

  static String selectCandidate(String id) => '$adminBase/candidates/$id/select';
}
