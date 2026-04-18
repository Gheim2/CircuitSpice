import 'package:flutter/material.dart';
import 'electronic_component.dart';

abstract class SymbolRenderer<T extends ElectronicComponent> {
  // Disegna il corpo principale del componente
  Color get baseColor => Colors.greenAccent; // Colore di default per il simbolo
  
  void drawSymbol(Canvas canvas, Size size, Paint paint);
  
  // (Opzionale) Se il componente ha logiche di disegno extra al suo interno
  void drawInnerSymbol(Canvas canvas, Paint paint, T component) {}
}