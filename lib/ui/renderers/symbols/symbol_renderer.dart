import 'package:flutter/material.dart';
import '../../../models/electronic_component.dart';

abstract class SymbolRenderer<T extends ElectronicComponent> {
  /// Disegna il corpo principale del componente
  void drawSymbol(Canvas canvas, Size size, Paint paint);
  
  /// (Opzionale) Se il componente ha logiche di disegno extra al suo interno
  void drawInnerSymbol(Canvas canvas, Paint paint, T component) {}
}