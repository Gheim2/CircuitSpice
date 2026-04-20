import 'package:flutter/material.dart';
import '../../logic/mna_context.dart';
import '../base/electronic_component.dart';
import '../base/node.dart';

class CurrentSource extends ElectronicComponent {
  CurrentSource({
    super.position = Offset.zero,
    super.name,
    super.value = 1.0,
    super.rotation = 0,
  });

  @override
  bool get drawCurrent => false;

  @override
  LabelPosition get defaultLabelPosition => LabelPosition.left;

  @override
  String get prefix => 'I';
  @override
  String get unit => 'A';

  @override
  ElectronicComponent clone(Offset newPosition) {
    return CurrentSource(position: newPosition, name: name, value: value, rotation: rotation);
  }

  @override
  List<ComponentNode> get nodes => [
    ComponentNode(const Offset(0, 40)),  // Nodo inferiore (pos)
    ComponentNode(const Offset(0, -40)), // Nodo superiore (neg)
  ];

  @override
  Rect get baseCollisionRect => Rect.fromCenter(center: Offset.zero, width: 40, height: 40);

  @override
  int get auxiliaryEquations => 0;

  @override
  void stamp(MNAContext ctx) {
    int nIn = pinNets[0] ?? -1;
    int nOut = pinNets[1] ?? -1;
    if (nIn == -1 || nOut == -1) return;
    double I = value; // La corrente che la sorgente fornisce (positiva da nIn a nOut)
    if (nIn > 0) ctx.Z[nIn - 1] -= I;
    if (nOut > 0) ctx.Z[nOut - 1] += I;
  }

  @override
  double calculateCurrent(MNAContext ctx, Map<int, double> nodeVoltages, List<double> x) {
    return value;
  }
}