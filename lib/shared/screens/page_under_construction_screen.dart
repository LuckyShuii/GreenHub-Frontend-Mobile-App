import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class PageUnderConstructionScreen extends StatelessWidget {
  const PageUnderConstructionScreen({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Retour \u00e0 l\'accueil',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
        ),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Page en construction \u2699\uFE0F',
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
          ),
        ),
      ),
    );
  }
}
