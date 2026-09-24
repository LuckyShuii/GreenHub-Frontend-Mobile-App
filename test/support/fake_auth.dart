import 'package:flutter_frontend/features/auth/data/auth_api_service.dart';
import 'package:flutter_frontend/features/auth/data/models/auth_tokens.dart';
import 'package:flutter_frontend/features/auth/data/models/login_request.dart';
import 'package:flutter_frontend/features/auth/data/models/user_response.dart';
import 'package:flutter_frontend/features/auth/data/token_storage.dart';

AuthTokens tokensGeneration(
  int generation, {
  Duration expiresIn = const Duration(minutes: 15),
}) {
  return AuthTokens(
    accessToken: 'access-$generation',
    refreshToken: 'refresh-$generation',
    expiresIn: expiresIn,
  );
}

UserResponse connectedUser({String email = 'ada@example.com'}) {
  return UserResponse(
    id: '00000000-0000-0000-0000-000000000001',
    firstName: 'Ada',
    lastName: 'Lovelace',
    email: email,
    username: 'ada',
    location: null,
    createdAt: DateTime(2026, 1, 1),
  );
}

class InMemoryTokenStorage implements TokenStorage {
  InMemoryTokenStorage([this.refreshToken, this.deviceId]);

  String? refreshToken;
  String? deviceId;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> writeRefreshToken(String refreshToken) async {
    this.refreshToken = refreshToken;
  }

  @override
  Future<String?> readDeviceId() async => deviceId;

  @override
  Future<void> writeDeviceId(String deviceId) async {
    this.deviceId = deviceId;
  }

  @override
  Future<void> clear() async {
    refreshToken = null;
  }
}

class FakeAuthApiService extends AuthApiService {
  FakeAuthApiService({
    this.onLogin,
    this.onRefresh,
    this.onLogout,
    this.onFetchCurrentUser,
  }) : super(baseUrl: 'http://localhost:8000');

  Future<AuthTokens> Function(LoginRequest request)? onLogin;
  Future<AuthTokens> Function(String refreshToken)? onRefresh;
  Future<void> Function(String refreshToken)? onLogout;
  Future<UserResponse> Function(String accessToken)? onFetchCurrentUser;

  final List<LoginRequest> loginRequests = <LoginRequest>[];
  final List<String> refreshedTokens = <String>[];
  final List<String> loggedOutTokens = <String>[];
  final List<String> accessTokensUsed = <String>[];

  @override
  Future<AuthTokens> login(LoginRequest request) async {
    loginRequests.add(request);
    return onLogin == null ? tokensGeneration(1) : onLogin!(request);
  }

  @override
  Future<AuthTokens> refresh(
    String refreshToken, {
    String? deviceInfo,
  }) async {
    refreshedTokens.add(refreshToken);
    return onRefresh == null
        ? tokensGeneration(refreshedTokens.length + 1)
        : onRefresh!(refreshToken);
  }

  @override
  Future<void> logout(String refreshToken) async {
    loggedOutTokens.add(refreshToken);
    if (onLogout != null) {
      await onLogout!(refreshToken);
    }
  }

  @override
  Future<UserResponse> fetchCurrentUser(String accessToken) async {
    accessTokensUsed.add(accessToken);
    return onFetchCurrentUser == null
        ? connectedUser()
        : onFetchCurrentUser!(accessToken);
  }
}
