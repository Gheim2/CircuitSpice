import 'package:flutter/material.dart';
import 'electronic_component.dart';
import 'node.dart';

class CurrentSource extends ElectronicComponent {
  CurrentSource({
    required super.position,
    super.name,
    super.value = 1.0,
    super.rotation = 0,
  });

  @override
  bool get drawCurrent => false;

  @override
  LabelPosition get defaultLabelPosition => LabelPosition.left;

  @override
  String get unit => 'A';

  @override
  ElectronicComponent clone(Offset newPosition) {
    return CurrentSource(position: newPosition, name: name, value: value, rotation: rotation);
  }

  @override
  List<ComponentNode> get nodes => [
    ComponentNode(const Offset(0, 40)),  // Nodo inferiore (pos)
    ComponentNode(const Offset(0, -40)), // Nodo superiore (neg)
  ];

  @override
  List<Offset> get relativeForbiddenPoints => [
    const Offset(0,0),
  ];

  @override
  Rect get baseCollisionRect => Rect.fromCenter(center: Offset.zero, width: 40, height: 40);

  @override
  Path get symbolPath {
    return Path()
      ..moveTo(0, -40)..lineTo(0, -20)
      ..moveTo(0, 20)..lineTo(0, 40)
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: 20))
      ..moveTo(-5, -5)..lineTo(0, -10)..lineTo(5, -5)
      ..moveTo(0, 10)..lineTo(0, -10);
  }

  // @override
  // void drawSymbol(Canvas canvas, Paint paint) {
  //   canvas.drawLine(const Offset(0, -40), const Offset(0, -20), paint);
  //   canvas.drawLine(const Offset(0, 20), const Offset(0, 40), paint);
  //   canvas.drawCircle(const Offset(0, 0), 20, paint);
  //   // ^
  //   final path = Path()
  //     ..moveTo(-5, -5)..lineTo(-0, -10)
  //     ..lineTo(5, -5);
  //   canvas.drawPath(path, paint..strokeJoin = StrokeJoin.miter);
  //   // |
  //   canvas.drawLine(const Offset(0, 10), const Offset(0, -10), paint);
  // }

}