import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../shared/config/api_config.dart';
import 'models/product_response.dart';

class NutritionApiException implements Exception {
  const NutritionApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Code-barres valide, mais aucun produit référencé — cas distinct
/// prévu explicitement par le ticket (message "Produit non référencé").
class ProductNotFoundException implements Exception {
  const ProductNotFoundException();
}

class NutritionApiService {
  NutritionApiService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  /// Récupère un produit à partir de son code-barres.
  ///
  /// Lève [ProductNotFoundException] si le produit n'est pas référencé,
  /// [NutritionApiException] pour toute autre erreur (réseau, serveur).
  Future<ProductResponse> fetchProduct(String barcode) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}/api/nutrition/$barcode');

    late final http.Response response;
    try {
      response = await _client.get(
        uri,
        headers: const <String, String>{'Accept': 'application/json'},
      );
    } on http.ClientException {
      // Message imposé par le ticket pour ce cas précis.
      throw const NutritionApiException('Connexion requise pour scanner');
    }

    if (response.statusCode == 404) {
      throw const ProductNotFoundException();
    }

    if (response.statusCode != 200) {
      throw NutritionApiException(
        'Le serveur a retourné une erreur inattendue.',
        statusCode: response.statusCode,
      );
    }

    try {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      return ProductResponse.fromJson(body);
    } on FormatException {
      throw const NutritionApiException('Réponse invalide du serveur.');
    }
  }
}
