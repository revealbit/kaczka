import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl => dotenv.env['API_BASE_URL']!;
  static String get wsBaseUrl => dotenv.env['WS_BASE_URL']!;

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  // Endpoints
  static const String authGoogleSignIn = '/auth/google';
  static const String authRefresh = '/auth/refresh';
  static const String authMe = '/auth/me';

  static const String sessionsStart = '/sessions/start';
  static const String sessionsSync = '/sessions/sync';
  static const String sessionsEnd = '/sessions/end';

  static const String tasks = '/tasks';
  static const String costumes = '/costumes';
  static const String shop = '/shop';
  static const String friends = '/friends';
  static const String challenges = '/challenges';
  static const String leaderboard = '/leaderboard';

  static const String gdprExport = '/me/export';
  static const String gdprDelete = '/me';
}
