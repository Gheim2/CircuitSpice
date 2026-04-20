import '../base/electronic_component.dart';
import '../base/node.dart';
import 'package:flutter/material.dart';

class NetLabel extends ElectronicComponent{
  NetLabel({
    super.position = Offset.zero,
    super.name = 'NET1',
    super.rotation = 0,
    super.showName = false,
    super.showValue = false,
  }) {
    labelsOffset = const Offset(30, 0);
  }

  @override
  String get prefix => 'NET';

  @override
  ElectronicComponent clone(Offset newPosition) {
    return NetLabel(position: newPosition, name: name, rotation: rotation, showName: showName, showValue: showValue);
  }

  @override
  bool get isValueEditable => false;

  @override
  List<ComponentNode> get nodes => [ComponentNode(Offset.zero)];

  @override
  Rect get baseCollisionRect => Rect.fromLTRB(3, -12, 62, 12);

}