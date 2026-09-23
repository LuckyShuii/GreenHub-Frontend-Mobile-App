import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models/auth_tokens.dart';
import 'models/login_request.dart';
import 'models/register_request.dart';
import 'models/user_response.dart';

class AuthApiException implements Exception {
  const AuthApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class AuthApiService {
  AuthApiService({String? baseUrl, http.Client? client})
    : _baseUrl = (baseUrl ?? _defaultBaseUrl).replaceFirst(RegExp(r'/$'), ''),
      _client = client ?? http.Client();

  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  final String _baseUrl;
  final http.Client _client;

  Future<UserResponse> register(RegisterRequest request) {
    return _call(
      () => _postJson('/api/auth/register', request.toJson()),
      (int statusCode, dynamic body) {
        if (statusCode == 201) {
          return UserResponse.fromJson(body as Map<String, dynamic>);
        }
        throw _failure(statusCode, body);
      },
    );
  }

  Future<AuthTokens> login(LoginRequest request) {
    return _call(
      () => _postJson('/api/auth/login', request.toJson()),
      _parseTokens,
    );
  }

  Future<AuthTokens> refresh(String refreshToken, {String? deviceInfo}) {
    final Map<String, dynamic> payload = <String, dynamic>{
      'refresh_token': refreshToken,
    };
    if (deviceInfo != null) {
      payload['device_info'] = deviceInfo;
    }
    return _call(
      () => _postJson('/api/auth/refresh', payload),
      _parseTokens,
    );
  }

  Future<void> logout(String refreshToken) {
    return _call(
      () => _postJson('/api/auth/logout', <String, dynamic>{
        'refresh_token': refreshToken,
      }),
      (int statusCode, dynamic body) {
        if (statusCode != 204) {
          throw _failure(statusCode, body);
        }
      },
    );
  }

  Future<UserResponse> fetchCurrentUser(String accessToken) {
    return _call(
      () => _client.get(
        _uri('/api/auth/me'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ),
      (int statusCode, dynamic body) {
        if (statusCode == 200) {
          return UserResponse.fromJson(body as Map<String, dynamic>);
        }
        throw _failure(statusCode, body);
      },
    );
  }

  AuthTokens _parseTokens(int statusCode, dynamic body) {
    if (statusCode == 200) {
      return AuthTokens.fromJson(body as Map<String, dynamic>);
    }
    throw _failure(statusCode, body);
  }

  Future<T> _call<T>(
    Future<http.Response> Function() send,
    T Function(int statusCode, dynamic body) handle,
  ) async {
    try {
      final http.Response response = await send();
      final dynamic decodedBody = response.body.isEmpty
          ? null
          : jsonDecode(response.body);
      return handle(response.statusCode, decodedBody);
    } on FormatException {
      throw const AuthApiException('Réponse invalide du serveur.');
    } on http.ClientException {
      throw const AuthApiException(
        'Impossible de contacter le serveur. Vérifiez votre connexion.',
      );
    }
  }

  Future<http.Response> _postJson(String path, Map<String, dynamic> body) {
    return _client.post(
      _uri(path),
      headers: const <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  AuthApiException _failure(int statusCode, dynamic body) {
    final String message = switch (statusCode) {
      401 => _errorMessage(body, fallback: 'Authentification refusée.'),
      409 => _errorMessage(body, fallback: 'Ce compte existe déjà.'),
      422 => _validationMessage(body),
      _ => 'Le serveur a retourné une erreur inattendue.',
    };
    return AuthApiException(message, statusCode: statusCode);
  }

  String _validationMessage(dynamic body) {
    if (body is Map<String, dynamic> && body['detail'] is List<dynamic>) {
      final List<dynamic> details = body['detail'] as List<dynamic>;
      if (details.isNotEmpty && details.first is Map<String, dynamic>) {
        final dynamic message = (details.first as Map<String, dynamic>)['msg'];
        if (message is String) {
          return message;
        }
      }
    }
    return 'Les données saisies sont invalides.';
  }

  String _errorMessage(dynamic body, {required String fallback}) {
    if (body is Map<String, dynamic> && body['detail'] is String) {
      return body['detail'] as String;
    }
    return fallback;
  }
}
