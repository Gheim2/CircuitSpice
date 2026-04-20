import 'package:flutter/material.dart';
import '../base/electronic_component.dart';
import '../base/node.dart';

// Implementazione specifica della Resistenza
class Resistor extends ElectronicComponent {
  Resistor({
    super.position = Offset.zero,
    super.name = '',
    super.value = 0.0,
    super.rotation = 0
    });

  @override
  String get prefix => 'R';
  
  @override
  String get unit => 'Ω';

  @override
  ElectronicComponent clone(Offset newPosition) {
    return Resistor(position: newPosition, name: name, value: value, rotation: rotation);
  }

  @override
  List<ComponentNode> get nodes => [
    ComponentNode(const Offset(-40, 0)), // Nodo di ingresso
    ComponentNode(const Offset(40, 0)),  // Nodo di uscita
  ];

  @override
  Rect get baseCollisionRect => Rect.fromCenter(center: Offset.zero, width: 50, height: 20);

}