import 'package:flutter/material.dart';
import '../../logic/mna_context.dart';
import '../base/electronic_component.dart';
import '../base/node.dart';

class VoltageSource extends ElectronicComponent {
  VoltageSource({super.position = Offset.zero, super.value = 0.0, super.name = '', super.rotation});

  int _mnaRow = -1; // Per tenere traccia della riga ausiliaria in MNA
  
  @override
  String get prefix => 'V';
  @override
  String get unit => 'V';

  @override
  ElectronicComponent clone(Offset newPosition) {
    return VoltageSource(position: newPosition, value: value, name: name, rotation: rotation);
  }

  @override
  LabelPosition get defaultLabelPosition => LabelPosition.right;

  @override
  List<ComponentNode> get nodes => [
    ComponentNode(const Offset(0, -40)), // Nodo di ingresso
    ComponentNode(const Offset(0, 40)),  // Nodo di uscita
  ];

  @override
  Rect get baseCollisionRect => Rect.fromCenter(center: Offset.zero, width: 40, height: 40);

  // MNA
  @override
  int get auxiliaryEquations => 1; // Serve una riga ausiliaria per la corrente della sorgente

  @override
  void stamp(MNAContext ctx) {
    int nPos = pinNets[0] ?? -1;
    int nNeg = pinNets[1] ?? -1;
    if (nNeg == -1 || nPos == -1) return;

    _mnaRow = ctx.allocateVoltageRow();

    if (nPos > 0) {
      ctx.A[nPos - 1][_mnaRow] += 1;
      ctx.A[_mnaRow][nPos - 1] += 1;
    }
    if (nNeg > 0) {
      ctx.A[nNeg - 1][_mnaRow] -= 1;
      ctx.A[_mnaRow][nNeg - 1] -= 1;
    }
    ctx.Z[_mnaRow] = value;
  }

  @override
  double calculateCurrent(MNAContext ctx, Map<int, double> nodeVoltages, List<double> x) {
    return _mnaRow != -1 ? x[_mnaRow] : 0.0;
  }
}