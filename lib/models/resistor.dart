import 'package:flutter/material.dart';
import 'electronic_component.dart';
import 'node.dart';

// Implementazione specifica della Resistenza
class Resistor extends ElectronicComponent {
  Resistor({
    required super.position,
    super.name = '',
    super.value = 0.0,
    super.rotation = 0
    });

  @override
  String get unit => 'Ω';

  @override
  List<ComponentNode> get nodes => [
    ComponentNode(const Offset(-40, 0)), // Nodo di ingresso
    ComponentNode(const Offset(40, 0)),  // Nodo di uscita
  ];

  @override
  List<Offset> get relativeForbiddenPoints => [
    const Offset(0,0),
  ];

  @override
  Rect get baseCollisionRect => Rect.fromCenter(center: Offset.zero, width: 50, height: 20);

  @override
  void drawSymbol(Canvas canvas, Paint paint) {
    final path = Path()
      ..moveTo(-40, 0)..lineTo(-30, 0)
      ..lineTo(-25, -10)..lineTo(-15, 10)..lineTo(-5, -10)..lineTo(5, 10)..lineTo(15, -10)..lineTo(25, 10)
      ..lineTo(30, 0)..lineTo(40, 0);
    canvas.drawPath(path, paint);
  }

}