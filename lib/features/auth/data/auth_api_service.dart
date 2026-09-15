import 'dart:convert';

import 'package:http/http.dart' as http;

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
  AuthApiService({
    String? baseUrl,
    http.Client? client,
  })  : _baseUrl = (baseUrl ?? _defaultBaseUrl).replaceFirst(RegExp(r'/$'), ''),
        _client = client ?? http.Client();

  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  final String _baseUrl;
  final http.Client _client;

  Future<UserResponse> register(RegisterRequest request) async {
    final Uri uri = Uri.parse('$_baseUrl/api/auth/register');

    try {
      final http.Response response = await _client.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final dynamic decodedBody = response.body.isEmpty
          ? null
          : jsonDecode(response.body);

      if (response.statusCode == 201) {
        return UserResponse.fromJson(decodedBody as Map<String, dynamic>);
      }

      if (response.statusCode == 409) {
        throw const AuthApiException(
          'Cette adresse e-mail est déjà utilisée.',
          statusCode: 409,
        );
      }

      if (response.statusCode == 422) {
        throw AuthApiException(
          _validationMessage(decodedBody),
          statusCode: 422,
        );
      }

      throw AuthApiException(
        'Le serveur a retourné une erreur inattendue.',
        statusCode: response.statusCode,
      );
    } on AuthApiException {
      rethrow;
    } on FormatException {
      throw const AuthApiException('Réponse invalide du serveur.');
    } on http.ClientException {
      throw const AuthApiException(
        'Impossible de contacter le serveur. Vérifiez votre connexion.',
      );
    }
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
}
