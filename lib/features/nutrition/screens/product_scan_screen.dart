import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../shared/widgets/app_notification_host_widget.dart';
import '../data/nutrition_api_service.dart';
import '../data/product_cache_service.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../widgets/scan_overlay_widget.dart';

class ProductScanScreen extends StatefulWidget {
  const ProductScanScreen({super.key});

  @override
  State<ProductScanScreen> createState() => _ProductScanScreenState();
}

class _ProductScanScreenState extends State<ProductScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const <BarcodeFormat>[
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
  );
  final NutritionApiService _apiService = NutritionApiService();
  final ProductCacheService _cacheService = const ProductCacheService();

  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) {
      return;
    }
    if (capture.barcodes.isEmpty) {
      return;
    }
    final String? barcode = capture.barcodes.first.rawValue;
    if (barcode == null) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });
    unawaited(HapticFeedback.mediumImpact());

    try {
      final product = await _apiService.fetchProduct(barcode);
      await _cacheService.addProduct(product.toCacheSummary());
      if (!mounted) {
        return;
      }
      await context.push<void>(AppRoutes.productResult, extra: product);
    } on ProductNotFoundException {
      if (!mounted) {
        return;
      }
      AppNotificationHost.of(context).showError('Produit non référencé');
    } on NutritionApiException catch (error) {
      if (!mounted) {
        return;
      }
      AppNotificationHost.of(context).showError(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Scanner un produit'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          MobileScanner(controller: _controller, onDetect: _onDetect),
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 48),
              child: ScanOverlayWidget(),
            ),
          ),
          if (_isProcessing)
            const ColoredBox(
              color: Color(0x88000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
