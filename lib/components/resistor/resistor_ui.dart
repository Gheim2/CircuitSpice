import 'package:flutter/material.dart';
import '../base/symbol_renderer.dart';
import 'resistor.dart';

class ResistorSymbol extends SymbolRenderer<Resistor> {
  @override
  void drawSymbol(Canvas canvas, Size size, Paint paint) {
    final path = Path()
      ..moveTo(-40, 0)..lineTo(-30, 0)
      ..lineTo(-25, -10)..lineTo(-15, 10)..lineTo(-5, -10)..lineTo(5, 10)..lineTo(15, -10)..lineTo(25, 10)
      ..lineTo(30, 0)..lineTo(40, 0);
    canvas.drawPath(path, paint);
  }

  @override
  void drawInnerSymbol(Canvas canvas, Paint paint, Resistor component) {
    // Lascia vuoto se non serve, o aggiungi dettagli specifici
  }
}