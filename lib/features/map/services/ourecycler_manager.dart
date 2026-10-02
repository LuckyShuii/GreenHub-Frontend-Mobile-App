import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_frontend/features/map/models/ourecycler_trash.dart';
import 'package:http/http.dart' as http;

class OurecyclerManager {
  final String baseUrl = dotenv.env['OURECYCLER_API_BASE_API']!;
  final String endpoint = dotenv.env['OURECYCLER_API_ENDPOINT']!;
  final String key = dotenv.env['OURECYCLER_API_KEY']!;

  Future<List<OurecyclerTrash>> getCollectionPoints({
    required String material,
    required double latitude,
    required double longitude,
    double radius = 15,
    int limit = 10,
    bool dechetterie = false,
    String? country,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint').replace(
      queryParameters: {
        'material': material,
        'lat': latitude.toString(),
        'lng': longitude.toString(),
        'radius': radius.toString(),
        'limit': limit.toString(),
        'dechetterie': dechetterie ? '1' : '0',
        if (country != null) 'country': country
      }
    );

    final response = await http.get(
      url,
      headers: {
        'X-API-Key': key,
        'Accept': 'application/json',
      },
    );

    final data = jsonDecode(response.body);
    final records = data['results'];
    return records.map<OurecyclerTrash>((records) =>
        OurecyclerTrash.fromJson(
            records as Map<String, dynamic>,
            material: material)
    ).toList();
  }
}
