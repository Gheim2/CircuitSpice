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
  void drawSymbol(Canvas canvas, Paint paint) {
    canvas.drawLine(Offset.zero, const Offset(15, 0), paint);
    
    // Disegniamo una piccola "bandierina" o tag
    final path = Path()
      ..moveTo(10, 0)
      ..lineTo(15, -10)
      ..lineTo(60, -10)
      ..lineTo(60, 10)
      ..lineTo(15, 10)
      ..close(); 
      
    canvas.drawPath(path, paint..style = PaintingStyle.fill);

    // Disegniamo il testo del nome
    if (name.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(text: name, style: const TextStyle(color: Colors.white, fontSize: 10)),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
      )..layout();
      
      double textX = 20;
      double textY = - (textPainter.height / 2);
      textPainter.paint(canvas, Offset(textX, textY));
    }
  }

}