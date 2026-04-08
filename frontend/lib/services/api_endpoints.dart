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

        if (current.host == 'localhost' || current.host == '127.0.0.1') {
          return '${current.scheme}://${current.host}:$_defaultPort';
        }

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

  static String get candidateBase => '$baseUrl/candidate';
  static String get adminBase => '$baseUrl/admin';

  static String get signup => '$candidateBase/apply';
  static String get adminLogin => '$adminBase/login';
  static String get adminRegister => '$adminBase/register';
  static String get candidates => '$adminBase/candidates';

  static String selectCandidate(String id) => '$adminBase/candidates/$id/select';
}
