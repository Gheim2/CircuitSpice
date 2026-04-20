import 'package:flutter/material.dart';
import '../base/electronic_component.dart';
import '../base/node.dart';

class VCVS extends ElectronicComponent {
  VCVS({super.position = Offset.zero, super.value = 0.0, super.name = '', super.rotation});

  @override
  String get prefix => 'Vc';
  @override
  String get unit => '';

  @override
  ElectronicComponent clone(Offset newPosition) {
    return VCVS(position: newPosition, value: value, name: name, rotation: rotation);
  }

  @override
  LabelPosition get defaultLabelPosition => LabelPosition.right;

  @override
  List<ComponentNode> get nodes => [
    ComponentNode(const Offset(0, -40)), // +
    ComponentNode(const Offset(0, 40)),  // -
    ComponentNode(const Offset(-40, -20)), // + pilot
    ComponentNode(const Offset(-40, 20)),  // - pilot
  ];

  @override
  Rect get baseCollisionRect => Rect.fromCenter(center: Offset.zero, width: 40, height: 40);

}