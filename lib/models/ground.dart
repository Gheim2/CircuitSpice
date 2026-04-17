import 'package:flutter/material.dart';
import 'electronic_component.dart';
import 'node.dart';

class Ground extends ElectronicComponent {
  Ground({super.position = Offset.zero}) : super(name: 'GND', value: 0, showName: false, showValue: false);

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

  // @override
  // Path get symbolPath {
  //   return Path()
  //     ..moveTo(0, 0)..lineTo(0, 10)
  //     ..moveTo(-15, 10)..lineTo(15, 10)
  //     ..moveTo(-10, 16)..lineTo(10, 16)
  //     ..moveTo(-5, 22)..lineTo(5, 22);
  // }
  
}