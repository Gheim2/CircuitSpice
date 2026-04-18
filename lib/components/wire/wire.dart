import 'dart:ui';
import 'dart:math' as math;

class Wire {
  final Offset start;
  final Offset end;

  int netId = -1;

  Wire(this.start, this.end);

  bool contains(Offset point) {
    double l2 = (start.dx - end.dx) * (start.dx - end.dx) + (start.dy - end.dy) * (start.dy - end.dy);
    // Se il filo è lungo zero, controlla solo la distanza dal punto
    if (l2 == 0) return (point - start).distance < 15.0; 

    // Troviamo la proiezione ortogonale del click sul segmento
    double t = ((point.dx - start.dx) * (end.dx - start.dx) + (point.dy - start.dy) * (end.dy - start.dy)) / l2;
    // Limitiamo 't' tra 0 e 1 per assicurarci di cliccare *sul* filo e non sul suo prolungamento immaginario
    t = math.max(0, math.min(1, t)); 
    
    Offset projection = Offset(start.dx + t * (end.dx - start.dx), start.dy + t * (end.dy - start.dy));
    
    // Se clicchiamo a meno di 15 pixel dal filo, lo abbiamo preso
    return (point - projection).distance < 15.0; 
  }

  double get length {
    return (end - start).distance;
  }

  Offset getMidpoint() {
    return Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
  }
}