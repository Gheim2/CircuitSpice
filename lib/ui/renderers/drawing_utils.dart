import 'package:flutter/material.dart';

class DrawingUtils {
  static void drawNetLabel({
    required Canvas canvas,
    required Offset center,
    required int netId,
    required Color color,
    double? voltage,
    double verticalOffset = 0.0,
    int decimalPlaces = 3,
  }) {
    String label = (netId == 0) ? 'GND' : 'Net $netId';
    if (voltage != null) {
      label += '\n${voltage.toStringAsFixed(decimalPlaces)} V';
    }
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(
              blurRadius: 3.0,
              color: Colors.black87,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final drawPos = center - Offset(textPainter.width / 2, textPainter.height / 2 + verticalOffset);
    textPainter.paint(canvas, drawPos);
  }
}