import 'package:flutter/material.dart';
import 'current_source.dart';
import '../../base/symbol_renderer.dart';

class CurrentSourceUI extends SymbolRenderer<CurrentSource> {
  
  @override
  void drawSymbol(Canvas canvas, Size size, Paint paint) {
    final path = Path()
      ..moveTo(0, -40)..lineTo(0, -20)
      ..moveTo(0, 20)..lineTo(0, 40)
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: 20));

    // E lo disegniamo
    canvas.drawPath(path, paint);
  }

  @override
  void drawInnerSymbol(Canvas canvas, Paint paint, CurrentSource? component) {
    final path = Path()
      ..moveTo(-5, -5)..lineTo(0, -10)..lineTo(5, -5) // Freccia
      ..moveTo(0, 10)..lineTo(0, -10); // Corpo freccia
    canvas.drawPath(path, paint);
  }
}