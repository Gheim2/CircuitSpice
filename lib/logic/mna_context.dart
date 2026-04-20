class MNAContext {
  final List<List<double>> A;
  final List<double> Z;
  final int numNodes;
  int _nextVoltageIndex;

  MNAContext(int matrixSize, this.numNodes)
    : A = List.generate(matrixSize, (_) => List.filled(matrixSize, 0.0)),
      Z = List.filled(matrixSize, 0.0),
      _nextVoltageIndex = numNodes;

  /// Restituisce la prossima riga/colonna disponibile per un'equazione KVL (es. VCVS o VSource)
  int allocateVoltageRow() {
    return _nextVoltageIndex++;
  }
}