import 'package:flutter/material.dart';
import '../base/electronic_component.dart';
import '../base/node.dart';

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
  
}