import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_radii.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../data/models/product_response.dart';
import '../widgets/product_score_badge_widget.dart';

class ProductResultScreen extends StatelessWidget {
  const ProductResultScreen({required this.product, super.key});

  final ProductResponse product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.o50,
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: AppColors.o50,
        elevation: 0,
        foregroundColor: AppColors.o900,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _sectionCard(
                title: 'Informations générales',
                child: Column(
                  children: <Widget>[
                    _infoRow(
                      'Marque',
                      product.brand,
                      'Quantité',
                      product.quantity,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    _infoRow(
                      'Catégorie',
                      product.category,
                      'Pays de vente',
                      product.countriesSold,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    _infoRow(
                      'Label',
                      product.label,
                      'Degrés transfo',
                      product.novaGroup?.toString() ?? '-',
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _scoreCard('Nutri-score', product.nutriScore),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(child: _scoreCard('Eco-score', product.ecoScore)),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              _sectionCard(
                title: 'Nutrition (100g)',
                child: Column(
                  children: <Widget>[
                    _valueRow(
                      'Calories',
                      _kcal(product.nutritionFacts.caloriesKcal),
                    ),
                    _valueRow('Lipides', _grams(product.nutritionFacts.fatG)),
                    _valueRow(
                      '  dont saturés',
                      _grams(product.nutritionFacts.saturatedFatG),
                    ),
                    _valueRow(
                      'Glucides',
                      _grams(product.nutritionFacts.carbohydratesG),
                    ),
                    _valueRow(
                      '  dont sucres',
                      _grams(product.nutritionFacts.sugarsG),
                    ),
                    _valueRow('Fibres', _grams(product.nutritionFacts.fiberG)),
                    _valueRow(
                      'Protéines',
                      _grams(product.nutritionFacts.proteinsG),
                    ),
                    _valueRow('Sel', _grams(product.nutritionFacts.saltG)),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              _sectionCard(
                title: 'Ingrédients',
                child: _listOrFallback(product.ingredients, 'Non renseigné'),
              ),
              SizedBox(height: AppSpacing.sm),
              _sectionCard(
                title: 'Allergène',
                child: _listOrFallback(
                  product.allergens,
                  'Aucun allergène signalé',
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              _sectionCard(
                title: 'Additif',
                child: _listOrFallback(
                  product.additives,
                  'Aucun additif signalé',
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              _sectionCard(
                title: 'Packaging',
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: <Widget>[
                    for (final String material in product.packaging)
                      _packagingChip(material),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  String _grams(double value) => '${value.toStringAsFixed(1)} g';
  String _kcal(double value) => '${value.toStringAsFixed(0)} kcal';

  Widget _listOrFallback(List<String> items, String fallback) {
    return Text(
      items.isEmpty ? fallback : items.join(', '),
      style: AppTextStyles.bodySmall,
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.o100),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: AppTextStyles.label),
          SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );
  }

  Widget _scoreCard(String title, String grade) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.o100),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(title, style: AppTextStyles.bodySmall)),
          ProductScoreBadgeWidget(grade: grade),
        ],
      ),
    );
  }

  Widget _infoRow(String label1, String value1, String label2, String value2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: _labelValue(label1, value1)),
        SizedBox(width: AppSpacing.sm),
        Expanded(child: _labelValue(label2, value2)),
      ],
    );
  }

  Widget _labelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: AppTextStyles.bodySmall),
        Text(
          value.isEmpty ? '-' : value,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _valueRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: AppTextStyles.bodySmall),
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _packagingChip(String material) {
    final Color color = switch (material.toLowerCase()) {
      'plastique' => AppColors.plastique,
      'papier' || 'papiers' || 'carton' => AppColors.carton,
      'verre' => AppColors.verre,
      'métal' || 'metal' || 'acier' || 'aluminium' => AppColors.metal,
      _ => AppColors.o300,
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        material,
        style: AppTextStyles.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
