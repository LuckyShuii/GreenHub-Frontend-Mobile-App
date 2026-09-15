import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_frontend/features/map/models/velib_station.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class VelibManager {
  String get _dataset {
    final dataset = dotenv.env['VELIB_PARIS_API_DATASET'];
    if (dataset == null || dataset.isEmpty) {
      throw Exception('VELIB_PARIS_API_DATASET est absente du fichier .env');
    }
    return dataset;
  }

  String get _baseUrl {
    final baseUrl = dotenv.env['VELIB_PARIS_API_BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('VELIB_PARIS_API_BASE_URL est absente du fichier .env');
    }
    return baseUrl;
  }

  Future<List<VelibStation>> getStations({
    required LatLng topLeft,
    required LatLng bottomRight,
    required LatLng referencePoint,
    int limit = 20
  }) async {
    final url = Uri.parse('$_baseUrl/$_dataset/records').replace(
        queryParameters: {
          'where': _buildBoundingBox(
            topLeft: topLeft,
            bottomRight: bottomRight,
          ),
          'order_by': _buildDistanceOrder(
              referencePoint: referencePoint
          ),
          'limit': limit.toString(),
        }
    );

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        debugPrint('Erreur API vélib: ${response.statusCode}');
        throw Exception(response.body);
      }
      final data = jsonDecode(response.body);
      final records = data['results'];
      if (records is! List) {
        throw Exception('Format de réponse Vélib invalide');
      }
      return records.map(
              (records) =>
              VelibStation.fromJson(
                  records as Map<String, dynamic>
              )
      ).toList();
    } catch (error) {
      debugPrint(
          'Erreur lors de la recuperation des stations de vélib: $error');
      rethrow;
    }
  }

  String _buildBoundingBox({
    required LatLng topLeft,
    required LatLng bottomRight
  }) {
    return 'in_bbox('
        'coordonnees_geo,'
        '${topLeft.latitude},'
        '${topLeft.longitude},'
        '${bottomRight.latitude},'
        '${bottomRight.longitude}'
        ')';
  }

  String _buildDistanceOrder({
    required LatLng referencePoint
  }) {
    return 'distance('
        'coordonnees_geo,'
        ' GEOM\'POINT('
        '${referencePoint.longitude} '
        '${referencePoint.latitude}'
        ')\''
        ') ASC'
    ;
  }
}
