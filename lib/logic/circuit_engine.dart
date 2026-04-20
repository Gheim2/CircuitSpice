import 'package:flutter/foundation.dart';
import 'package:equations/equations.dart';
import '../components/core.dart';
import 'mna_context.dart';

class CircuitEngine {
  final List<ElectronicComponent> components;
  final int totalNets;

  CircuitEngine(this.components, this.totalNets);

  Map<int, double> nodeVoltages = {};
  Map<ElectronicComponent, double> componentCurrents = {};

  void solve() {
    int numNodes = totalNets;
    // Calcoliamo m = righe extra necessarie
    int m = components.fold(0, (sum, comp) => sum + comp.auxiliaryEquations);
    int matrixSize = numNodes + m;
    if (matrixSize == 0) return;

    final ctx = MNAContext(matrixSize, numNodes);
    for (var comp in components) {
      comp.stamp(ctx);
    }
    if (kDebugMode) {print("Dimensione Matrice MNA: $matrixSize x $matrixSize");}

    try {
      final matrixA = RealMatrix.fromData(
        rows: matrixSize, 
        columns: matrixSize, 
        data: ctx.A);
      final solver = GaussianElimination(matrix: matrixA, knownValues: ctx.Z);
      final x = solver.solve();
      nodeVoltages[0] = 0.0; // Nodo di riferimento (GND)
      for (int i = 0; i < numNodes; i++) {
        nodeVoltages[i + 1] = x[i];
      }
      for (var comp in components) {
        componentCurrents[comp] = comp.calculateCurrent(ctx, nodeVoltages, x);
      }
    } catch (e) {
      if (kDebugMode) {print("Errore nella risoluzione del circuito: $e");}
    }
    
  }
}