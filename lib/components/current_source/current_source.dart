import 'package:flutter/material.dart';
import '../base/electronic_component.dart';
import '../base/node.dart';

class CurrentSource extends ElectronicComponent {
  CurrentSource({
    super.position = Offset.zero,
    super.name,
    super.value = 1.0,
    super.rotation = 0,
  });

  @override
  bool get drawCurrent => false;

  @override
  LabelPosition get defaultLabelPosition => LabelPosition.left;

  @override
  String get prefix => 'I';
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

}