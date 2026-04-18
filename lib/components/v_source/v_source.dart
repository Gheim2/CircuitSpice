import 'package:flutter/material.dart';
import '../base/electronic_component.dart';
import '../base/node.dart';

class VoltageSource extends ElectronicComponent {
  VoltageSource({super.position = Offset.zero, super.value = 0.0, super.name = '', super.rotation});

  @override
  String get prefix => 'V';
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

}