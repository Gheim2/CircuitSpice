class EngineeringUtils {
  static final Map<String, double> _suffixes = {
    'p': 1e-12, 'n': 1e-9, 'u': 1e-6, 'm': 1e-3,
    'k': 1e3, 'M': 1e6, 'G': 1e9, 'T': 1e12
  };

  // Da Stringa a Numero (Es: "4.7k" -> 4700.0)
  static double parseValue(String text) {
    // Pulizia iniziale: rimuove spazi e accetta la virgola italiana
    text = text.trim().replaceAll(' ', '').replaceAll(',', '.');
    if (text.isEmpty) return 0.0;

    String lastChar = text[text.length - 1];
    if (_suffixes.containsKey(lastChar)) {
      // Estrae il numero senza la lettera e lo moltiplica per il suffisso
      double val = double.tryParse(text.substring(0, text.length - 1)) ?? 0.0;
      return val * _suffixes[lastChar]!;
    }

    return double.tryParse(text) ?? 0.0; // Nessun suffisso
  }

  // Da Numero a Stringa (Es: 10000.0 -> "10 k")
  static String formatValue(double value) {
    if (value.abs() < 1e-15) return '0';
    final absVal = value.abs();
    
    String formatNum(double num) {
      // Rimuove i decimali inutili (es: 10.0 -> 10)
      return (num == num.toInt()) ? num.toInt().toString() : num.toStringAsFixed(3);
    }

    if (absVal >= 1e12) return '${formatNum(value / 1e12)} T';
    if (absVal >= 1e9)  return '${formatNum(value / 1e9)} G';
    if (absVal >= 1e6)  return '${formatNum(value / 1e6)} M';
    if (absVal >= 1e3)  return '${formatNum(value / 1e3)} k';
    if (absVal >= 1)    return formatNum(value);
    if (absVal >= 1e-3) return '${formatNum(value * 1e3)} m';
    if (absVal >= 1e-6) return '${formatNum(value * 1e6)} u';
    if (absVal >= 1e-9) return '${formatNum(value * 1e9)} n';
    if (absVal >= 1e-12) return '${formatNum(value * 1e12)} p';
    
    return value.toStringAsFixed(3);
  }
}