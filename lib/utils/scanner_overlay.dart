import 'package:flutter/material.dart';

class ScannerOverlay extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  ScannerOverlay(
    this.borderColor, {
    this.borderWidth = 8.0,
    this.borderRadius = 24.0,
    this.borderLength = 32.0,
    this.cutOutSize = 300.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(rect),
      Path()..addRRect(
        RRect.fromRectAndRadius(cutoutRect, Radius.circular(borderRadius)),
      ),
    );

    canvas.drawPath(path, backgroundPaint);

    // Draw corners
    const double padding = 8.0;
    final corners = [
      // Top left
      [
        Offset(cutoutRect.left - padding, cutoutRect.top + borderLength),
        Offset(cutoutRect.left - padding, cutoutRect.top - padding),
        Offset(cutoutRect.left + borderLength, cutoutRect.top - padding),
      ],
      // Top right
      [
        Offset(cutoutRect.right - borderLength, cutoutRect.top - padding),
        Offset(cutoutRect.right + padding, cutoutRect.top - padding),
        Offset(cutoutRect.right + padding, cutoutRect.top + borderLength),
      ],
      // Bottom right
      [
        Offset(cutoutRect.right + padding, cutoutRect.bottom - borderLength),
        Offset(cutoutRect.right + padding, cutoutRect.bottom + padding),
        Offset(cutoutRect.right - borderLength, cutoutRect.bottom + padding),
      ],
      // Bottom left
      [
        Offset(cutoutRect.left + borderLength, cutoutRect.bottom + padding),
        Offset(cutoutRect.left - padding, cutoutRect.bottom + padding),
        Offset(cutoutRect.left - padding, cutoutRect.bottom - borderLength),
      ],
    ];

    for (final corner in corners) {
      final path = Path();
      path.moveTo(corner[0].dx, corner[0].dy);
      path.lineTo(corner[1].dx, corner[1].dy);
      path.lineTo(corner[2].dx, corner[2].dy);
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
