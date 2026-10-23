/// Valeurs nutritionnelles pour 100g, telles qu'affichées sur la fiche
/// produit (maquette "Nutrition").
class NutritionFacts {
  const NutritionFacts({
    required this.caloriesKcal,
    required this.fatG,
    required this.saturatedFatG,
    required this.carbohydratesG,
    required this.sugarsG,
    required this.fiberG,
    required this.proteinsG,
    required this.saltG,
  });

  final double caloriesKcal;
  final double fatG;
  final double saturatedFatG;
  final double carbohydratesG;
  final double sugarsG;
  final double fiberG;
  final double proteinsG;
  final double saltG;

  factory NutritionFacts.fromJson(Map<String, dynamic> json) {
    return NutritionFacts(
      caloriesKcal: _asDouble(json['calories_kcal']),
      fatG: _asDouble(json['fat_g']),
      saturatedFatG: _asDouble(json['saturated_fat_g']),
      carbohydratesG: _asDouble(json['carbohydrates_g']),
      sugarsG: _asDouble(json['sugars_g']),
      fiberG: _asDouble(json['fiber_g']),
      proteinsG: _asDouble(json['proteins_g']),
      saltG: _asDouble(json['salt_g']),
    );
  }

  static double _asDouble(dynamic value) => value is num ? value.toDouble() : 0;
}

/// Fiche produit complète, telle que retournée par l'API nutrition.
class ProductResponse {
  const ProductResponse({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.quantity,
    required this.category,
    required this.countriesSold,
    required this.label,
    required this.novaGroup,
    required this.nutriScore,
    required this.ecoScore,
    required this.nutritionFacts,
    required this.ingredients,
    required this.allergens,
    required this.additives,
    required this.packaging,
  });

  final String barcode;
  final String name;
  final String brand;
  final String quantity;
  final String category;
  final String countriesSold;
  final String label;
  final int? novaGroup;
  final String nutriScore;
  final String ecoScore;
  final NutritionFacts nutritionFacts;
  final List<String> ingredients;
  final List<String> allergens;
  final List<String> additives;
  final List<String> packaging;

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      barcode: json['barcode'] as String? ?? '',
      name: json['name'] as String? ?? 'Produit sans nom',
      brand: json['brand'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '',
      category: json['category'] as String? ?? '',
      countriesSold: json['countries_sold'] as String? ?? '',
      label: json['label'] as String? ?? '',
      novaGroup: json['nova_group'] as int?,
      nutriScore: (json['nutri_score'] as String? ?? '?').toUpperCase(),
      ecoScore: (json['eco_score'] as String? ?? '?').toUpperCase(),
      nutritionFacts: NutritionFacts.fromJson(
        json['nutrition_facts'] as Map<String, dynamic>? ??
            const <String, dynamic>{},
      ),
      ingredients: _asStringList(json['ingredients']),
      allergens: _asStringList(json['allergens']),
      additives: _asStringList(json['additives']),
      packaging: _asStringList(json['packaging']),
    );
  }

  /// Version condensée pour le cache local (étape 3) — on ne garde que
  /// l'essentiel pour l'historique, pas tout le détail nutritionnel.
  Map<String, dynamic> toCacheSummary() {
    return <String, dynamic>{
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'nutri_score': nutriScore,
      'eco_score': ecoScore,
    };
  }

  static List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return const <String>[];
  }
}
