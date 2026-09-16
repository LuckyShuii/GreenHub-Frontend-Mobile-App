import 'dart:convert';

import 'package:flutter_frontend/features/auth/data/auth_api_service.dart';
import 'package:flutter_frontend/features/auth/data/models/register_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const RegisterRequest request = RegisterRequest(
    firstName: 'Antoine',
    lastName: 'Ribeyre',
    email: 'antoine@example.com',
    username: 'ant_oine',
    location: 'Paris, France',
    password: 'Abcdefghij1!',
  );

  for (final String message in <String>[
    'Cette adresse e-mail est déjà utilisée.',
    'Ce pseudonyme est déjà utilisé.',
  ]) {
    test('propagates the API conflict detail: $message', () async {
      final AuthApiService service = AuthApiService(
        baseUrl: 'http://localhost:8000',
        client: MockClient((http.Request request) async {
          return http.Response(
            jsonEncode(<String, String>{'detail': message}),
            409,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }),
      );

      await expectLater(
        service.register(request),
        throwsA(
          isA<AuthApiException>()
              .having(
                (AuthApiException error) => error.statusCode,
                'statusCode',
                409,
              )
              .having(
                (AuthApiException error) => error.message,
                'message',
                message,
              ),
        ),
      );
    });
  }
}
