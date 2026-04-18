import 'package:flutter/material.dart';
import 'dart:math' as math;

class ComponentNode {
  final Offset relativePosition; // Posizione rispetto al centro del componente
  
  ComponentNode(this.relativePosition);

  // Calcola dove si trova il nodo nel mondo (sulla griglia 10000x10000)
  Offset getGlobalPosition(Offset compPos, int rotation) {
    double angle = rotation * math.pi / 180;
    double cosA = math.cos(angle);
    double sinA = math.sin(angle);

    // Rotazione del vettore locale
    double rotatedX = relativePosition.dx * cosA - relativePosition.dy * sinA;
    double rotatedY = relativePosition.dx * sinA + relativePosition.dy * cosA;

    return Offset(compPos.dx + rotatedX, compPos.dy + rotatedY);
  }
}