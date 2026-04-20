import 'package:flutter/material.dart';
import '../../../logic/mna_context.dart';
import '../../base/electronic_component.dart';
import '../../base/node.dart';

class VCCS extends ElectronicComponent {
  VCCS({super.position = Offset.zero, super.value = 1.0, super.name = '', super.rotation});

  @override
  String get prefix => 'Ic';
  @override
  String get unit => 'S';

  @override
  ElectronicComponent clone(Offset newPosition) {
    return VCCS(position: newPosition, value: value, name: name, rotation: rotation);
  }

  @override
  LabelPosition get defaultLabelPosition => LabelPosition.right;

  @override
  List<ComponentNode> get nodes => [
    ComponentNode(const Offset(0, 40)),  // ^
    ComponentNode(const Offset(0, -40)), // |
    ComponentNode(const Offset(-40, -20)), // + pilot
    ComponentNode(const Offset(-40, 20)),  // - pilot
  ];

  @override
  Rect get baseCollisionRect => Rect.fromCenter(center: Offset.zero, width: 40, height: 40);

  @override
  int get auxiliaryEquations => 0; 

  @override
  void stamp(MNAContext ctx) {
    int nCurOut = pinNets[0] ?? -1;
    int nCurIn = pinNets[1] ?? -1;
    int nCPos = pinNets[2] ?? -1;
    int nCNeg = pinNets[3] ?? -1;

    if (nCurIn == -1 || nCurOut == -1 || nCPos == -1 || nCNeg == -1) return;
    double gm = value;

    // Nodo di uscita KCL
    if (nCurOut > 0) {
      if (nCPos > 0) ctx.A[nCurOut - 1][nCPos - 1] += gm;
      if (nCNeg > 0) ctx.A[nCurOut - 1][nCNeg - 1] -= gm;
    }
    // Nodo di ingresso KCL
    if (nCurIn > 0) {
      if (nCPos > 0) ctx.A[nCurIn - 1][nCPos - 1] -= gm;
      if (nCNeg > 0) ctx.A[nCurIn - 1][nCNeg - 1] += gm;
    }
  }

  @override
  double calculateCurrent(MNAContext ctx, Map<int, double> nodeVoltages, List<double> x) {
    int nCurOutPos = pinNets[2] ?? -1;
    int nCurOutNeg = pinNets[3] ?? -1;
    double vInPos = (nCurOutPos <= 0) ? 0.0 : (nodeVoltages[nCurOutPos] ?? 0.0);
    double vInNeg = (nCurOutNeg <= 0) ? 0.0 : (nodeVoltages[nCurOutNeg] ?? 0.0);
    
    return value * (vInPos - vInNeg);}
}