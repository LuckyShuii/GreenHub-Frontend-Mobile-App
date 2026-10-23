import 'package:flutter/material.dart';

/// Rectangle de cadrage avec coins en L, dessiné par-dessus l'aperçu
/// caméra pour guider l'utilisateur (voir maquette "Scan page").
class ScanOverlayWidget extends StatelessWidget {
  const ScanOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(painter: _ScanCornersPainter()),
    );
  }
}

class _ScanCornersPainter extends CustomPainter {
  const _ScanCornersPainter();

  static const double _cornerLength = 32;
  static const double _strokeWidth = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    void drawCorner(Offset corner, Offset horizontal, Offset vertical) {
      canvas.drawLine(corner, horizontal, paint);
      canvas.drawLine(corner, vertical, paint);
    }

    drawCorner(
      Offset.zero,
      const Offset(_cornerLength, 0),
      const Offset(0, _cornerLength),
    );
    drawCorner(
      Offset(size.width, 0),
      Offset(size.width - _cornerLength, 0),
      Offset(size.width, _cornerLength),
    );
    drawCorner(
      Offset(0, size.height),
      Offset(_cornerLength, size.height),
      Offset(0, size.height - _cornerLength),
    );
    drawCorner(
      Offset(size.width, size.height),
      Offset(size.width - _cornerLength, size.height),
      Offset(size.width, size.height - _cornerLength),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
