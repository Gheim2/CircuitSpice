import 'dart:math' as math;

// import 'package:flutter/material.dart';
import 'dart:ui';
import 'node.dart';
import '../../logic/engineering_utils.dart';

enum LabelPosition { top, right, bottom, left }

// Una classe base per tutti i componenti elettronici
abstract class ElectronicComponent {
  Offset position;
  int rotation; // 0, 90, 180, 270 gradi
  String name;
  double value;
  bool showName;
  bool showValue;
  bool isSelected;
  Map<int, int> pinNets = {}; // Mappa pinIndex -> netId

  Offset labelsOffset = const Offset(0,-35);
  Size labelSize = Size.zero;

  ElectronicComponent({
    required this.position, 
    this.name = '',
    this.value = 0.0,
    this.rotation = 0, 
    this.isSelected = false,
    this.showName = true,
    this.showValue = true,
  }) {
    labelsOffset = _getDefaultLabelsOffset();
  }

  bool get drawCurrent => true;
  LabelPosition get defaultLabelPosition => LabelPosition.top;
  String get prefix => '';
  String get unit => ''; // Override nelle sottoclassi per unità specifiche
  bool get isValueEditable => true;
  double get currentArrowOffsetY => 25.0;
  String get formattedValue => '${EngineeringUtils.formatValue(value)}$unit';

  ElectronicComponent clone(Offset newPosition);

  List<ComponentNode> get nodes;
  Rect get baseCollisionRect;

  // Metodi di posizione / collisione
  List<Offset> get globalNodePositions => 
      nodes.map((n) => n.getGlobalPosition(position, rotation)).toList();

  List<Offset> get relativeForbiddenPoints => [Offset.zero];

  List<Offset> get globalForbiddenPoints =>
    relativeForbiddenPoints.map((p) => getGlobalPosition(p)).toList();

  Rect get collisionBox {
    Offset rotatedCenter = getGlobalPosition(baseCollisionRect.center);
    double w = rotation % 180 == 0 ? baseCollisionRect.width : baseCollisionRect.height;
    double h = rotation % 180 == 0 ? baseCollisionRect.height : baseCollisionRect.width;
    return Rect.fromCenter(center: rotatedCenter, width: w, height: h);
  }

  bool contains(Offset point) { return collisionBox.contains(point); }

  Rect get labelsHitbox {
    if (labelSize == Size.zero) return Rect.zero;
    Offset globalPos = getGlobalPosition(labelsOffset);
    return Rect.fromCenter(
      center: globalPos,
      width: labelSize.width + 16,
      height: labelSize.height + 16
    );
  }

  Offset getGlobalPosition(Offset relative) {
    double rad = rotation * math.pi / 180;
    double dx = relative.dx * math.cos(rad) - relative.dy * math.sin(rad);
    double dy = relative.dx * math.sin(rad) + relative.dy * math.cos(rad);
    return position + Offset(dx, dy);
  }

  Offset _getDefaultLabelsOffset() {
    switch (defaultLabelPosition) {
      case LabelPosition.top: return const Offset(0, -35);
      case LabelPosition.right: return const Offset(40, 0);
      case LabelPosition.bottom: return const Offset(0, 35);
      case LabelPosition.left: return const Offset(-40, 0);
    }
  }

  // void drawInnerSymbol(Canvas canvas, Paint paint) {}

}
