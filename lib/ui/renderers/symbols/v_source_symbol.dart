import 'package:flutter/material.dart';
import 'symbol_renderer.dart';
import '../../../models/v_source.dart';

class VSourceSymbol implements SymbolRenderer<VoltageSource> {
  @override
  void drawSymbol(Canvas canvas, Size size, Paint paint) {
    final path = Path()
      ..moveTo(0, -40)..lineTo(0, -20)
      ..moveTo(0, 20)..lineTo(0, 40)
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: 20))
      ..moveTo(-5, -10)..lineTo(5, -10)
      ..moveTo(0, -15)..lineTo(0, -5)
      ..moveTo(-5, 10)..lineTo(5, 10);
    canvas.drawPath(path, paint);
  }

  @override
  void drawInnerSymbol(Canvas canvas, Paint paint, VoltageSource component) {
    // Lascia vuoto se non serve, o aggiungi dettagli specifici
  }
}