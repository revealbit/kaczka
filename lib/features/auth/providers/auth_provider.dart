import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../data/remote/api_client.dart';
import '../../../domain/models/user.dart';

part 'auth_provider.g.dart';

// ---------------------------------------------------------------------------
// Infrastructure providers
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) =>
    const FlutterSecureStorage();

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage: storage);
}

@Riverpod(keepAlive: true)
GoogleSignIn googleSignIn(Ref ref) =>
    GoogleSignIn(scopes: ['email', 'profile']);

// ---------------------------------------------------------------------------
// Auth state
// ---------------------------------------------------------------------------

sealed class AuthState {
  const AuthState();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final User user;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

// ---------------------------------------------------------------------------
// Auth notifier
// ---------------------------------------------------------------------------

/// DEV MODE: set to true to skip Google Sign-In and use a local mock user.
const bool kDevBypassAuth = true;

const _devUser = User(
  id: 'dev-user-001',
  username: 'dev_duck',
  email: 'dev@kaczka.local',
  totalPoints: 1500,
  currentPoints: 1200,
  level: 4,
  streakDays: 7,
);

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  Future<AuthState> build() async {
    if (kDevBypassAuth) return const AuthAuthenticated(_devUser);
    return _tryRestoreSession();
  }

  Future<AuthState> _tryRestoreSession() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: ApiConstants.tokenKey);
    if (token == null) return const AuthUnauthenticated();

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get<Map<String, dynamic>>(ApiConstants.authMe);
      final user = User.fromJson(response.data!);
      return AuthAuthenticated(user);
    } catch (_) {
      await storage.delete(key: ApiConstants.tokenKey);
      await storage.delete(key: ApiConstants.refreshTokenKey);
      return const AuthUnauthenticated();
    }
  }

  Future<void> signInWithGoogle() async {
    if (kDevBypassAuth) {
      state = const AsyncValue.data(AuthAuthenticated(_devUser));
      return;
    }

    state = const AsyncValue.loading();

    try {
      final googleSignIn = ref.read(googleSignInProvider);
      final account = await googleSignIn.signIn();
      if (account == null) {
        state = const AsyncValue.data(AuthUnauthenticated());
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('Google ID token is null');

      final client = ref.read(apiClientProvider);
      final response = await client.post<Map<String, dynamic>>(
        ApiConstants.authGoogleSignIn,
        data: {'id_token': idToken},
      );

      final storage = ref.read(secureStorageProvider);
      await storage.write(
        key: ApiConstants.tokenKey,
        value: response.data!['access_token'] as String,
      );
      await storage.write(
        key: ApiConstants.refreshTokenKey,
        value: response.data!['refresh_token'] as String,
      );

      final user = User.fromJson(response.data!['user'] as Map<String, dynamic>);
      state = AsyncValue.data(AuthAuthenticated(user));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    if (kDevBypassAuth) {
      state = const AsyncValue.data(AuthAuthenticated(_devUser));
      return;
    }

    final storage = ref.read(secureStorageProvider);
    final googleSignIn = ref.read(googleSignInProvider);

    await Future.wait([
      storage.delete(key: ApiConstants.tokenKey),
      storage.delete(key: ApiConstants.refreshTokenKey),
      googleSignIn.signOut(),
    ]);

    state = const AsyncValue.data(AuthUnauthenticated());
  }
}
