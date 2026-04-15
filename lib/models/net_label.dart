import 'package:circuit_spice/models/electronic_component.dart';
import 'package:circuit_spice/models/node.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class NetLabel extends ElectronicComponent{
  NetLabel({
    required super.position,
    super.name = 'NET1',
    super.rotation = 0,
    super.showValue = false,
  }) {
    labelsOffset = const Offset(30, 0);
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
  Rect get baseCollisionRect => Rect.fromCenter(center: const Offset(20, 0), width: 40, height: 20);
  
  @override
  void drawSymbol(Canvas canvas, Paint paint) {
    canvas.drawLine(Offset.zero, const Offset(15, 0), paint);
    
    // Disegniamo una piccola "bandierina" o tag
    final path = Path()
      ..moveTo(10, 0)
      ..lineTo(15, -8)
      ..lineTo(60, -8)
      ..lineTo(60, 8)
      ..lineTo(15, 8)
      ..close(); 
      
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

}