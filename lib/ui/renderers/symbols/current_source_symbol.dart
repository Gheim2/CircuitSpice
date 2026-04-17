import 'package:flutter/material.dart';
import '../../../models/current_source.dart';
import 'symbol_renderer.dart';

class CurrentSourceSymbol implements SymbolRenderer<CurrentSource> {
  
  @override
  void drawSymbol(Canvas canvas, Size size, Paint paint) {
    final path = Path()
      ..moveTo(0, -40)..lineTo(0, -20)
      ..moveTo(0, 20)..lineTo(0, 40)
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: 20))
      // La freccia interna
      ..moveTo(-5, -5)..lineTo(0, -10)..lineTo(5, -5)
      ..moveTo(0, 10)..lineTo(0, -10);

    // E lo disegniamo
    canvas.drawPath(path, paint);
  }

  @override
  void drawInnerSymbol(Canvas canvas, Paint paint, CurrentSource component) {
  }
}