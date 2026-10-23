import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Garde une petite liste des derniers produits alimentaires scannés,
/// pour un accès rapide même sans connexion.
class ProductCacheService {
  const ProductCacheService();

  static const String _storageKey = 'nutrition_scanned_products';
  static const int _maxEntries = 10;

  /// Ajoute [product] en tête de liste. Si un produit avec le même
  /// `barcode` existe déjà, il est retiré avant réinsertion (pour le
  /// faire remonter en tête sans doublon).
  Future<void> addProduct(Map<String, dynamic> product) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> current = await _readAll(prefs);

    final String? barcode = product['barcode'] as String?;
    current.removeWhere(
      (Map<String, dynamic> item) => item['barcode'] == barcode,
    );

    final List<Map<String, dynamic>> updated = <Map<String, dynamic>>[
      product,
      ...current,
    ].take(_maxEntries).toList();

    await prefs.setString(_storageKey, jsonEncode(updated));
  }

  /// Les derniers produits scannés, du plus récent au plus ancien.
  /// Liste vide si rien n'est en cache ou si les données stockées
  /// sont corrompues (ne doit jamais planter l'app pour ça).
  Future<List<Map<String, dynamic>>> getCachedProducts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return _readAll(prefs);
  }

  Future<List<Map<String, dynamic>>> _readAll(SharedPreferences prefs) async {
    final String? raw = prefs.getString(_storageKey);
    if (raw == null) {
      return <Map<String, dynamic>>[];
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } on FormatException {
      return <Map<String, dynamic>>[];
    }
  }
}
