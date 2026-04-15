import 'package:flutter/material.dart';
import 'electronic_component.dart';
import 'node.dart';

class VoltageSource extends ElectronicComponent {
  VoltageSource({required super.position, super.value = 0.0, super.name = '', super.rotation});

  @override
  String get unit => 'V';

  @override
  ElectronicComponent clone(Offset newPosition) {
    return VoltageSource(position: newPosition, value: value, name: name, rotation: rotation);
  }

  @override
  List<Offset> get relativeForbiddenPoints => [
    const Offset(0,0),
  ];

  @override
  LabelPosition get defaultLabelPosition => LabelPosition.right;

  @override
  List<ComponentNode> get nodes => [
    ComponentNode(const Offset(0, -40)), // Nodo di ingresso
    ComponentNode(const Offset(0, 40)),  // Nodo di uscita
  ];

  @override
  Rect get baseCollisionRect => Rect.fromCenter(center: Offset.zero, width: 40, height: 40);

  @override
  Path get symbolPath {
    return Path()
      ..moveTo(0, -40)..lineTo(0, -20)
      ..moveTo(0, 20)..lineTo(0, 40)
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: 20))
      ..moveTo(-5, -10)..lineTo(5, -10)
      ..moveTo(0, -15)..lineTo(0, -5)
      ..moveTo(-5, 10)..lineTo(5, 10);
  }
  // @override
  // void drawSymbol(Canvas canvas, Paint paint) {
  //   canvas.drawLine(const Offset(0, -40), const Offset(0, -20), paint);
  //   canvas.drawLine(const Offset(0, 20), const Offset(0, 40), paint);
  //   canvas.drawCircle(const Offset(0, 0), 20, paint);
  //   // +
  //   canvas.drawLine(const Offset(-5, -10), const Offset(5, -10), paint);
  //   canvas.drawLine(const Offset(0, -15), const Offset(0, -5), paint);
  //   // -
  //   canvas.drawLine(const Offset(-5, 10), const Offset(5, 10), paint);
  // }
}