import 'package:flutter/material.dart';
import 'electronic_component.dart';
import 'node.dart';

class Ground extends ElectronicComponent {
  Ground({required super.position}) : super(name: 'GND', value: 0, showName: false, showValue: false);

  @override
  bool get isValueEditable => false;

  @override
  ElectronicComponent clone(Offset newPosition) {
    return Ground(position: newPosition);
  }

  @override
  List<Offset> get relativeForbiddenPoints => [
    const Offset(0,20),
  ];

  @override
  List<ComponentNode> get nodes => [
    ComponentNode(const Offset(0, 0))
  ];

  @override
  Rect get baseCollisionRect => Rect.fromCenter(center: Offset(0, 10), width: 30, height: 25);

  @override
  void drawSymbol(Canvas canvas, Paint paint) {
    canvas.drawLine(const Offset(0, 0), const Offset(0, 10), paint);
    canvas.drawLine(const Offset(-15, 10), const Offset(15, 10), paint);
    canvas.drawLine(const Offset(-10, 16), const Offset(10, 16), paint);
    canvas.drawLine(const Offset(-5, 22), const Offset(5, 22), paint);
  }
  
}