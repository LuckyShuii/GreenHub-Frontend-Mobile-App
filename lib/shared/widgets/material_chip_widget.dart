import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Énumération des types de matières pour le tri sélectif
enum MaterialType { verre, plastique, carton, metal }

/// Mapping des couleurs pour chaque type de matière
extension MaterialTypeColor on MaterialType {
  Color get color {
    switch (this) {
      case MaterialType.verre:
        return AppColors.verre;
      case MaterialType.plastique:
        return AppColors.plastique;
      case MaterialType.carton:
        return AppColors.carton;
      case MaterialType.metal:
        return AppColors.metal;
    }
  }

  String get label {
    switch (this) {
      case MaterialType.verre:
        return 'Verre';
      case MaterialType.plastique:
        return 'Plastique';
      case MaterialType.carton:
        return 'Carton';
      case MaterialType.metal:
        return 'Métal';
    }
  }
}

/// Chip réutilisable pour afficher un type de matière
class MaterialChipWidget extends StatelessWidget {
  const MaterialChipWidget({
    super.key,
    required this.materialType,
    this.isSelected = false,
    this.onPressed,
  });

  final MaterialType materialType;
  final bool isSelected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        materialType.label,
        style: AppTextStyles.label.copyWith(
          color: isSelected ? Colors.white : materialType.color,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onPressed?.call(),
      backgroundColor: Colors.white,
      selectedColor: materialType.color,
      side: BorderSide(
        color: materialType.color,
        width: isSelected ? 0 : 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
    );
  }
}
