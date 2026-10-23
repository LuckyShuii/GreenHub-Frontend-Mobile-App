import 'package:flutter_frontend/features/auth/data/auth_api_service.dart';
import 'package:flutter_frontend/features/auth/data/models/auth_tokens.dart';
import 'package:flutter_frontend/features/auth/data/models/change_password_request.dart';
import 'package:flutter_frontend/features/auth/data/models/login_request.dart';
import 'package:flutter_frontend/features/auth/data/models/profile_update_request.dart';
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

UserResponse connectedUser({
  String email = 'ada@example.com',
  String firstName = 'Ada',
}) {
  return UserResponse(
    id: '00000000-0000-0000-0000-000000000001',
    firstName: firstName,
    lastName: 'Lovelace',
    email: email,
    username: 'ada',
    postalCode: null,
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
    this.onUpdateCurrentUser,
    this.onChangePassword,
    this.onDeleteCurrentUser,
  }) : super(baseUrl: 'http://localhost:8000');

  Future<AuthTokens> Function(LoginRequest request)? onLogin;
  Future<AuthTokens> Function(String refreshToken)? onRefresh;
  Future<void> Function(String refreshToken)? onLogout;
  Future<UserResponse> Function(String accessToken)? onFetchCurrentUser;
  Future<UserResponse> Function(
    String accessToken,
    ProfileUpdateRequest request,
  )?
  onUpdateCurrentUser;
  Future<void> Function(String accessToken, ChangePasswordRequest request)?
  onChangePassword;
  Future<void> Function(String accessToken)? onDeleteCurrentUser;

  final List<LoginRequest> loginRequests = <LoginRequest>[];
  final List<String> refreshedTokens = <String>[];
  final List<String> loggedOutTokens = <String>[];
  final List<String> accessTokensUsed = <String>[];
  final List<ProfileUpdateRequest> profileUpdates = <ProfileUpdateRequest>[];
  final List<ChangePasswordRequest> passwordChanges = <ChangePasswordRequest>[];
  final List<String> deletedAccounts = <String>[];

  @override
  Future<AuthTokens> login(LoginRequest request) async {
    loginRequests.add(request);
    return onLogin == null ? tokensGeneration(1) : onLogin!(request);
  }

  @override
  Future<AuthTokens> refresh(String refreshToken, {String? deviceInfo}) async {
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

  @override
  Future<UserResponse> updateCurrentUser(
    String accessToken,
    ProfileUpdateRequest request,
  ) async {
    accessTokensUsed.add(accessToken);
    profileUpdates.add(request);
    return onUpdateCurrentUser == null
        ? connectedUser()
        : onUpdateCurrentUser!(accessToken, request);
  }

  @override
  Future<void> changePassword(
    String accessToken,
    ChangePasswordRequest request,
  ) async {
    accessTokensUsed.add(accessToken);
    passwordChanges.add(request);
    await onChangePassword?.call(accessToken, request);
  }

  @override
  Future<void> deleteCurrentUser(String accessToken) async {
    accessTokensUsed.add(accessToken);
    deletedAccounts.add(accessToken);
    await onDeleteCurrentUser?.call(accessToken);
  }
}
