import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'node.dart';
import '../logic/engineering_utils.dart';

enum LabelPosition { top, right, bottom, left }

// Una classe base per tutti i componenti elettronici
abstract class ElectronicComponent {
  Offset position;
  int rotation; // 0, 90, 180, 270 gradi
  String name;
  bool showName;
  bool showValue;
  double value;
  bool isSelected;
  Map<int, int> pinNets = {}; // Mappa pinIndex -> netId

  Offset labelsOffset = const Offset(0,-35);
  Size _lastLabelSize = Size.zero;

  ElectronicComponent({
    required this.position, 
    this.name = '',
    this.value = 0.0,
    this.rotation = 0, 
    this.isSelected = false,
    this.showName = true,
    this.showValue = true,
  }) {
    labelsOffset = _getDefaultLabelsOffest();
  }

  // Ogni sottoclasse definirà i propri nodi locali
  Color get componentColor => isSelected ? Colors.orangeAccent : Colors.cyanAccent;
  LabelPosition get defaultLabelPosition => LabelPosition.top;
  String get unit => ''; // Override nelle sottoclassi per unità specifiche
  bool get isValueEditable => true;
  double get currentArrowOffsetY => 25.0;

  ElectronicComponent clone(Offset newPosition);

  Offset _getDefaultLabelsOffest() {
    switch (defaultLabelPosition) {
      case LabelPosition.top: return const Offset(0, -35);
      case LabelPosition.right: return const Offset(40, 0);
      case LabelPosition.bottom: return const Offset(0, 35);
      case LabelPosition.left: return const Offset(-40, 0);
    }
  }

  List<ComponentNode> get nodes;

  List<Offset> get globalNodePositions => 
      nodes.map((n) => n.getGlobalPosition(position, rotation)).toList();

  List<Offset> get relativeForbiddenPoints => [Offset.zero];

  List<Offset> get globalForbiddenPoints =>
    relativeForbiddenPoints.map((p) => _getGlobalPosition(p)).toList();

  Rect get baseCollisionRect;

  Rect get collisionBox {
    Offset rotatedCenter = _getGlobalPosition(baseCollisionRect.center);
    double w = rotation % 180 == 0 ? baseCollisionRect.width : baseCollisionRect.height;
    double h = rotation % 180 == 0 ? baseCollisionRect.height : baseCollisionRect.width;
    return Rect.fromCenter(center: rotatedCenter, width: w, height: h);
  }

  bool contains(Offset point) { return collisionBox.contains(point); }

  Rect get labelsHitbox {
    if (_lastLabelSize == Size.zero) return Rect.zero;
    Offset globalPos = _getGlobalPosition(labelsOffset);
    return Rect.fromCenter(
      center: globalPos,
      width: _lastLabelSize.width + 16,
      height: _lastLabelSize.height + 16
    );
  }

  void drawSymbol(Canvas canvas, Paint paint);

  void draw(Canvas canvas, Paint paint, {double? current}){ // current è opzionale
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation * math.pi / 180);
    
    final compPaint = Paint()
      ..color = componentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    // Chiama il metodo specifico del figlio (es. Resistenza o Batteria)
    drawSymbol(canvas, compPaint);
    
    // Disegno dei Nodi per tutti i componenti in automatico
    for (var node in nodes) {
      canvas.drawCircle(node.relativePosition, 3, compPaint..style = PaintingStyle.fill);
      compPaint.style = PaintingStyle.stroke;
    }
    
    canvas.restore();

    _drawLabels(canvas);
    if (current != null) drawCurrentArrow(canvas, current);
  }

  void _drawLabels(Canvas canvas) {
    String finalText = "";
    if (showName && name.isNotEmpty) finalText += name;
    if (showValue && formattedValue.isNotEmpty) {
      if (finalText.isNotEmpty) finalText += '\n';
      finalText += formattedValue;
    }
    if (finalText.isEmpty) {
      _lastLabelSize = Size.zero;
      return;
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: finalText,
        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, shadows: [
          Shadow(
            blurRadius: 3.0,
            color: Colors.black87,
            offset: const Offset(1, 1),
          ),
        ]),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    _lastLabelSize = textPainter.size;
    Offset globalPos = _getGlobalPosition(labelsOffset);
    textPainter.paint(canvas, globalPos - Offset(textPainter.width / 2, textPainter.height / 2));
  }


  void drawCurrentArrow(Canvas canvas, double current) {
    if (nodes.length < 2) return;
    Offset p0 = _getGlobalPosition(nodes[0].relativePosition);
    Offset p1 = _getGlobalPosition(nodes[1].relativePosition);
    double angle = math.atan2(p1.dy - p0.dy, p1.dx - p0.dx);
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle); // Ruota in direzione del flusso di corrente

    final currentPaint = Paint()
      ..color = Colors.yellowAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    double cy = currentArrowOffsetY;
    canvas.drawLine(Offset(-15, cy), Offset(15, cy), currentPaint); // Linea base
    canvas.drawLine(Offset(10, cy - 5), Offset(15, cy), currentPaint);  // Punta
    canvas.drawLine(Offset(10, cy + 5), Offset(15, cy), currentPaint);  // Punta
    canvas.restore();

    final currentText = TextPainter(
      text: TextSpan(
        text: '${EngineeringUtils.formatValue(current)}A',
        style: const TextStyle(
          color: Colors.yellowAccent, 
          fontSize: 11, 
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)]
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    
    // Lo posizioniamo in base all'angolo per tenerlo vicino alla freccia
    double textOffsetX = position.dx + math.cos(angle + math.pi/2) * (cy+15) - currentText.width / 2;
    double textOffsetY = position.dy + math.sin(angle + math.pi/2) * (cy+15) - currentText.height / 2;
    
    currentText.paint(canvas, Offset(textOffsetX, textOffsetY));
  }
  String get formattedValue => '${EngineeringUtils.formatValue(value)}$unit';

  Offset _getGlobalPosition(Offset relative) {
    double rad = rotation * math.pi / 180;
    double dx = relative.dx * math.cos(rad) - relative.dy * math.sin(rad);
    double dy = relative.dx * math.sin(rad) + relative.dy * math.cos(rad);
    return position + Offset(dx, dy);
  }

}
