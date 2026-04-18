import 'package:flutter/material.dart';
import '../base/symbol_renderer.dart';
import 'ground.dart';

class GroundSymbol implements SymbolRenderer<Ground> {
  @override
  void drawSymbol(Canvas canvas, Size size, Paint paint) {
    final path = Path()
      ..moveTo(0, 0)..lineTo(0, 10)
      ..moveTo(-15, 10)..lineTo(15, 10)
      ..moveTo(-10, 16)..lineTo(10, 16)
      ..moveTo(-5, 22)..lineTo(5, 22);
    canvas.drawPath(path, paint);
  }

  @override
  void drawInnerSymbol(Canvas canvas, Paint paint, Ground component) {
    // Lascia vuoto se non serve, o aggiungi dettagli specifici
  }
}

    