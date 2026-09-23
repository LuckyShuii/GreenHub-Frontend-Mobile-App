import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'auth_api_service.dart';
import 'models/auth_tokens.dart';
import 'models/login_request.dart';
import 'models/user_response.dart';
import 'token_storage.dart';

enum AuthStatus { unauthenticated, authenticated }

class AuthSession extends ChangeNotifier {
  AuthSession({
    required AuthApiService authApiService,
    required TokenStorage tokenStorage,
    DateTime Function()? clock,
  }) : _api = authApiService,
       _storage = tokenStorage,
       _clock = clock ?? DateTime.now;

  // Renouvelle un peu avant l'echeance pour qu'aucun jeton n'expire en plein trajet reseau.
  static const Duration _expiryMargin = Duration(seconds: 30);

  static const AuthApiException _sessionExpired = AuthApiException(
    'Session expirée. Veuillez vous reconnecter.',
    statusCode: 401,
  );

  final AuthApiService _api;
  final TokenStorage _storage;
  final DateTime Function() _clock;

  AuthStatus _status = AuthStatus.unauthenticated;
  String? _refreshToken;
  String? _accessToken;
  DateTime? _accessTokenExpiresAt;
  Future<String?>? _pendingRefresh;
  String? _deviceId;

  AuthStatus get status => _status;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> restore() async {
    String? refreshToken;
    try {
      refreshToken = await _storage.readRefreshToken();
      _deviceId = await _storage.readDeviceId();
      _deviceId ??= await _createDeviceId();
    } on Exception {
      // Keystore illisible (ex. apres restauration Android) : l'utilisateur se reconnecte.
      refreshToken = null;
    }

    _refreshToken = refreshToken;
    _setStatus(
      refreshToken == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated,
    );
  }

  Future<void> login({required String email, required String password}) async {
    final String deviceId = await _getDeviceId();
    final AuthTokens tokens = await _api.login(
      LoginRequest(
        email: email,
        password: password,
        deviceInfo: deviceId,
      ),
    );
    await _storeTokens(tokens);
    _setStatus(AuthStatus.authenticated);
  }

  Future<String?> getValidAccessToken() {
    final String? accessToken = _accessToken;
    final DateTime? expiresAt = _accessTokenExpiresAt;
    if (accessToken != null &&
        expiresAt != null &&
        _clock().isBefore(expiresAt)) {
      return Future<String?>.value(accessToken);
    }

    // Un seul refresh en vol : deux rotations concurrentes passeraient pour un vol cote serveur.
    return _pendingRefresh ??= _refreshTokens().whenComplete(() {
      _pendingRefresh = null;
    });
  }

  Future<T> authorizedCall<T>(
    Future<T> Function(String accessToken) call,
  ) async {
    final String? accessToken = await getValidAccessToken();
    if (accessToken == null) {
      throw _sessionExpired;
    }

    try {
      return await call(accessToken);
    } on AuthApiException catch (error) {
      if (error.statusCode != 401) {
        rethrow;
      }
      // Horloge du telephone decalee : le serveur a juge le jeton expire avant nous.
      if (_accessToken == accessToken) {
        _accessToken = null;
      }
      final String? retryToken = await getValidAccessToken();
      if (retryToken == null) {
        throw _sessionExpired;
      }
      return call(retryToken);
    }
  }

  Future<UserResponse> fetchCurrentUser() {
    return authorizedCall(_api.fetchCurrentUser);
  }

  Future<void> logout() async {
    final String? refreshToken = _refreshToken;
    if (refreshToken != null) {
      try {
        await _api.logout(refreshToken);
      } on AuthApiException {
        // La deconnexion locale prime, meme hors ligne : la session expirera cote serveur.
      }
    }
    await _clearSession();
  }

  Future<String?> _refreshTokens() async {
    final String? refreshToken = _refreshToken;
    if (refreshToken == null) {
      return null;
    }

    try {
      final String deviceId = await _getDeviceId();
      final AuthTokens tokens = await _api.refresh(
        refreshToken,
        deviceInfo: deviceId,
      );
      await _storeTokens(tokens);
      return tokens.accessToken;
    } on AuthApiException catch (error) {
      if (error.statusCode != 401) {
        rethrow;
      }
      await _clearSession();
      return null;
    }
  }

  Future<void> _storeTokens(AuthTokens tokens) async {
    _refreshToken = tokens.refreshToken;
    _accessToken = tokens.accessToken;
    _accessTokenExpiresAt = _clock().add(tokens.expiresIn - _expiryMargin);
    try {
      await _storage.writeRefreshToken(tokens.refreshToken);
    } on Exception {
      // Sans ecriture, l'ancien jeton deja tourne declencherait la detection de vol au redemarrage.
      await _clearStorage();
    }
  }

  Future<void> _clearSession() async {
    _refreshToken = null;
    _accessToken = null;
    _accessTokenExpiresAt = null;
    await _clearStorage();
    _setStatus(AuthStatus.unauthenticated);
  }

  Future<void> _clearStorage() async {
    try {
      await _storage.clear();
    } on Exception {
      // Rien de plus a faire : la prochaine connexion ecrasera la valeur illisible.
    }
  }

  Future<String> _getDeviceId() async {
    if (_deviceId != null) {
      return _deviceId!;
    }

    final String? storedDeviceId = await _storage.readDeviceId();
    _deviceId = storedDeviceId ?? await _createDeviceId();
    return _deviceId!;
  }

  Future<String> _createDeviceId() async {
    final Random random = Random.secure();
    final List<int> bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final String deviceId = base64UrlEncode(bytes);
    await _storage.writeDeviceId(deviceId);
    return deviceId;
  }

  void _setStatus(AuthStatus status) {
    if (_status == status) {
      return;
    }
    _status = status;
    notifyListeners();
  }
}
