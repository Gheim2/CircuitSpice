import 'package:circuit_spice/models/electronic_component.dart';
import 'package:circuit_spice/models/node.dart';
import 'package:flutter/material.dart';

class NetLabel extends ElectronicComponent{
  NetLabel({
    required super.position,
    super.name = 'NET1',
    super.rotation = 0,
    super.showName = false,
    super.showValue = false,
  }) {
    labelsOffset = const Offset(30, 0);
  }

  @override
  ElectronicComponent clone(Offset newPosition) {
    return NetLabel(position: newPosition, name: name, rotation: rotation, showName: showName, showValue: showValue);
  }

  @override
  bool get fillSymbolPath => true;

  @override
  bool get isValueEditable => false;

  @override
  Color get componentColor => isSelected ? Colors.orangeAccent : Colors.purpleAccent;

  @override
  List<ComponentNode> get nodes => [ComponentNode(Offset.zero)];

  @override
  List<Offset> get relativeForbiddenPoints => [Offset(40, 0)];

  @override
  Rect get baseCollisionRect => Rect.fromLTRB(3, -12, 62, 12);//Rect.fromCenter(center: const Offset(20, 0), width: 40, height: 20);
  
  @override
  Path get symbolPath {
    return Path()
      ..moveTo(10,0)
      ..lineTo(15, -10)..lineTo(60, -10)..lineTo(60, 10)..lineTo(15, 10)..close();
  }

  @override
  void drawInnerSymbol(Canvas canvas, Paint paint) {
    // 1. Disegniamo la linea di attacco (la teniamo fuori dal Path principale per non riempirla)
    canvas.drawLine(Offset.zero, const Offset(15, 0), paint);

    // 2. Disegniamo il testo del nome DENTRO il componente
    if (name.isNotEmpty) {
      Color textColor = paint.color == Colors.white ? Colors.black : Colors.white;
      final tp = TextPainter(
        text: TextSpan(
          text: name,
          style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, height: 1.0),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(15 + (45 - tp.width) / 2, -tp.height / 2));
    }
  }

}