import 'package:flutter/material.dart';
import '../base/electronic_component.dart';
import '../base/node.dart';
import '../../logic/mna_context.dart';

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

  // MNA
  @override
  void stamp(MNAContext ctx) {
    int n1 = pinNets[0] ?? -1;
    int n2 = pinNets[1] ?? -1;
    if (n1 == -1 || n2 == -1) return;

    double g = 1.0 / value;
    if (n1 > 0) ctx.A[n1 - 1][n1 - 1] += g;
    if (n2 > 0) ctx.A[n2 - 1][n2 - 1] += g;
    if (n1 > 0 && n2 > 0) {
      ctx.A[n1 - 1][n2 - 1] -= g;
      ctx.A[n2 - 1][n1 - 1] -= g;
    }
  }

  @override
  double calculateCurrent(MNAContext ctx, Map<int, double> nodeVoltages, List<double> x) {
    int n1 = pinNets[0] ?? -1;
    int n2 = pinNets[1] ?? -1;
    if (n1 == -1 || n2 == -1) return 0.0;
    double v1 = (n1 == 0) ? 0.0 : (nodeVoltages[n1] ?? 0.0);
    double v2 = (n2 == 0) ? 0.0 : (nodeVoltages[n2] ?? 0.0);
    return (v1 - v2) / value;
  }
}