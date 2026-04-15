import 'package:circuit_spice/models/current_source.dart';
import 'package:flutter/foundation.dart';

import '../models/electronic_component.dart';
import '../models/resistor.dart';
import '../models/v_source.dart';
import 'package:equations/equations.dart';

class CircuitEngine {
  final List<ElectronicComponent> components;
  final int totalNets;

  CircuitEngine(this.components, this.totalNets);

  Map<int, double> nodeVoltages = {};

  Map<ElectronicComponent, double> componentCurrents = {};

  void solve() {
    int numNodes = totalNets;
    List<VoltageSource> vSources = components.whereType<VoltageSource>().toList();
    int m = vSources.length;
    int matrixSize = numNodes + m;
    if (matrixSize == 0) return;

    List<List<double>> A = List.generate(matrixSize, (_) => List.filled(matrixSize, 0.0));
    List<double> Z = List.filled(matrixSize, 0.0);

    int vIndex = 0; // Contatore per le sorgenti di tensione
    for (var comp in components) {
      if (comp is Resistor) {
        int n1 = comp.pinNets[0] ?? -1;
        int n2 = comp.pinNets[1] ?? -1;
        if (n1 == -1 || n2 == -1) continue; // Ignora componenti non connessi
        double g = 1.0 / comp.value; // Conduttanza
        // Diagonali (Autoconduttanza)
        if (n1 > 0) A[n1 - 1][n1 - 1] += g;
        if (n2 > 0) A[n2 - 1][n2 - 1] += g;

        // Incroci (Conduttanza Mutua)
        if (n1 > 0 && n2 > 0) {
          A[n1 - 1][n2 - 1] -= g;
          A[n2 - 1][n1 - 1] -= g;
        }
      }
      else if (comp is VoltageSource) {
        int nPos = comp.pinNets[0] ?? -1; // Nodo negativo
        int nNeg = comp.pinNets[1] ?? -1; // Nodo positivo
        if (nNeg == -1 || nPos == -1) continue; // Ignora componenti non connessi
        int row = numNodes + vIndex; // Riga dedicata alla KVL della sorgente
        if (nPos > 0) {
          A[nPos - 1][row] += 1; // V(nPos) - V(nNeg) = Vsource
          A[row][nPos - 1] += 1;
        }
        if (nNeg > 0) {
          A[nNeg - 1][row] -= 1;
          A[row][nNeg - 1] -= 1;
        }
        Z[row] = comp.value; // Valore della sorgente di tensione
        vIndex++;
      } else if (comp is CurrentSource) {
        int nPos = comp.pinNets[0] ?? -1; // Nodo di ingresso (pos)
        int nNeg = comp.pinNets[1] ?? -1; // Nodo di uscita (neg)
        if (nNeg == -1 || nPos == -1) continue; // Ignora componenti non connessi
        if (nPos > 0) Z[nPos - 1] -= comp.value; // Corrente che esce dal nodo positivo
        if (nNeg > 0) Z[nNeg - 1] += comp.value; // Corrente che entra nel nodo negativo
      }
    }
    if (kDebugMode) {print("Dimensione Matrice MNA: $matrixSize x $matrixSize");}
    // Per evitare problemi di matrice singolare, aggiungiamo una piccola conduttanza a terra per ogni nodo (tolleranza numerica)
    // for (int i = 0; i < numNodes; i++) {
    //   A[i][i] += 1e-12; 
    // }
    try {
      final matrixA = RealMatrix.fromData(
        rows: matrixSize, 
        columns: matrixSize, 
        data: A);
      final solver = GaussianElimination(matrix: matrixA, knownValues: Z);
      final x = solver.solve();
      nodeVoltages[0] = 0.0; // Nodo di riferimento (terra)
      for (int i = 0; i < numNodes; i++) {
        nodeVoltages[i + 1] = x[i];
      }
      int vIdx = 0;
      for (var comp in components) {
        if (comp is VoltageSource) {
          componentCurrents[comp] = x[numNodes + vIdx];
          vIdx++;
        }
        else if (comp is Resistor) {
          int n1 = comp.pinNets[0] ?? -1;
          int n2 = comp.pinNets[1] ?? -1;
          if(n1 == -1 || n2 == -1) {componentCurrents[comp] = 0.0; continue;}
          double v1 = (n1 == 0) ? 0.0 : (nodeVoltages[n1] ?? 0.0); // ?? means "if null, use 0.0"
          double v2 = (n2 == 0) ? 0.0 : (nodeVoltages[n2] ?? 0.0);
          componentCurrents[comp] = (v1 - v2) / comp.value;
        }
        else if (comp is CurrentSource) {
          // La corrente nelle sorgenti di corrente è già nota
          componentCurrents[comp] = comp.value;
        }
      }
      if (kDebugMode) {
        print("Tensioni ai nodi:");
        nodeVoltages.forEach((netId, voltage) =>
          print("Net $netId: ${voltage.toStringAsFixed(4)} V"));
        print("Correnti nelle sorgenti di tensione:");
        componentCurrents.forEach((comp, current) =>
          print("${comp.name}: ${current.toStringAsFixed(4)} A"));
      }
    }
    catch (e) {
      if (kDebugMode) {print("Errore nella risoluzione del circuito: $e");}
    }
  }
}