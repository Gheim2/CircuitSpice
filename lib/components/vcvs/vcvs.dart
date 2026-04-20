import 'package:flutter/material.dart';
import '../../logic/mna_context.dart';
import '../base/electronic_component.dart';
import '../base/node.dart';

class VCVS extends ElectronicComponent {
  VCVS({super.position = Offset.zero, super.value = 0.0, super.name = '', super.rotation});

  int _mnaRow = -1; // Per tenere traccia della riga ausiliaria in MNA

  @override
  String get prefix => 'Vc';
  @override
  String get unit => '';

  @override
  ElectronicComponent clone(Offset newPosition) {
    return VCVS(position: newPosition, value: value, name: name, rotation: rotation);
  }

  @override
  LabelPosition get defaultLabelPosition => LabelPosition.right;

  @override
  List<ComponentNode> get nodes => [
    ComponentNode(const Offset(0, -40)), // +
    ComponentNode(const Offset(0, 40)),  // -
    ComponentNode(const Offset(-40, -20)), // + pilot
    ComponentNode(const Offset(-40, 20)),  // - pilot
  ];

  @override
  Rect get baseCollisionRect => Rect.fromCenter(center: Offset.zero, width: 40, height: 40);

  @override
  int get auxiliaryEquations => 1; // Serve una riga ausiliaria per la corrente della sorgente

  @override
  void stamp(MNAContext ctx) {
    int nOutPos = pinNets[0] ?? -1;
    int nOutNeg = pinNets[1] ?? -1;
    int nCPos = pinNets[2] ?? -1;
    int nCNeg = pinNets[3] ?? -1;

    if (nOutPos == -1 || nOutNeg == -1 || nCPos == -1 || nCNeg == -1) return;

    _mnaRow = ctx.allocateVoltageRow();
    double E = value; // Il 'value' per il VCVS è il guadagno

    // 1. KCL: La corrente entra e esce dai terminali di USCITA
    if (nOutPos > 0) ctx.A[nOutPos - 1][_mnaRow] += 1;
    if (nOutNeg > 0) ctx.A[nOutNeg - 1][_mnaRow] -= 1;

    // 2. KVL: Equazione dipendente
    if (nOutPos > 0) ctx.A[_mnaRow][nOutPos - 1] += 1;
    if (nOutNeg > 0) ctx.A[_mnaRow][nOutNeg - 1] -= 1;
    
    // I terminali di controllo (C) dettano il potenziale ma non assorbono corrente
    if (nCPos > 0) ctx.A[_mnaRow][nCPos - 1] -= E;
    if (nCNeg > 0) ctx.A[_mnaRow][nCNeg - 1] += E;

    ctx.Z[_mnaRow] = 0.0;
  }

  @override
  double calculateCurrent(MNAContext ctx, Map<int, double> nodeVoltages, List<double> x) {
    return _mnaRow != -1 ? x[_mnaRow] : 0.0;
  }
}