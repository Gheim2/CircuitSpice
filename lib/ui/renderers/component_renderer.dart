import 'dart:math' as math;
import 'package:circuit_spice/logic/engineering_utils.dart';
import 'package:circuit_spice/components/components.dart';
import 'package:flutter/material.dart';

class ComponentRenderer {

  static final Map<Type, SymbolRenderer> _renderRegistry = {
    CurrentSource: CurrentSourceSymbol(),
    Resistor: ResistorSymbol(),
    NetLabel: NetLabelSymbol(),
    Ground: GroundSymbol(),
    VoltageSource: VSourceSymbol(),
  };

  static void draw(Canvas canvas, ElectronicComponent comp, {Paint? compPaint, bool drawLabels = true}){
    canvas.save();
    canvas.translate(comp.position.dx, comp.position.dy);
    canvas.rotate(comp.rotation * math.pi / 180);
    
    compPaint ??= Paint()
        ..color = Colors.greenAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeJoin = StrokeJoin.round;
    final renderer = _renderRegistry[comp.runtimeType];
    if (renderer != null) {
      renderer.drawSymbol(canvas, comp.baseCollisionRect.size, compPaint);
      renderer.drawInnerSymbol(canvas, compPaint, comp);
    } else {
      canvas.drawRect(comp.baseCollisionRect, Paint()..color = Colors.red);
    }
    
    final nodePaint = Paint()
      ..color = compPaint.color
      ..style = PaintingStyle.fill;
    // Disegno dei Nodi per tutti i componenti in automatico
    for (var node in comp.nodes) {
      canvas.drawCircle(node.relativePosition, 3, nodePaint);
      compPaint.style = PaintingStyle.stroke;
    }
    canvas.restore();
    if (drawLabels) {
      _drawLabels(canvas, comp);
    }

  }

  static void _drawLabels(Canvas canvas, ElectronicComponent comp) {
    String finalText = "";
    if (comp.showName && comp.name.isNotEmpty) finalText += comp.name;
    if (comp.showValue && comp.formattedValue.isNotEmpty) {
      if (finalText.isNotEmpty) finalText += '\n';
      finalText += comp.formattedValue;
    }
    if (finalText.isEmpty) {
      comp.labelSize = Size.zero;
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

    comp.labelSize = textPainter.size;
    Offset globalPos = comp.getGlobalPosition(comp.labelsOffset);
    textPainter.paint(canvas, globalPos - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  static void drawCurrentArrow(Canvas canvas, ElectronicComponent comp, double current) {
    if (comp.nodes.length < 2 || !comp.drawCurrent) return;
    Offset p0 = comp.getGlobalPosition(comp.nodes[0].relativePosition);
    Offset p1 = comp.getGlobalPosition(comp.nodes[1].relativePosition);
    double angle = math.atan2(p1.dy - p0.dy, p1.dx - p0.dx);
    canvas.save();
    canvas.translate(comp.position.dx, comp.position.dy);
    canvas.rotate(angle); // Ruota in direzione del flusso di corrente

    final currentPaint = Paint()
      ..color = Colors.yellowAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    double cy = comp.currentArrowOffsetY;
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
    double textOffsetX = comp.position.dx + math.cos(angle + math.pi/2) * (cy+15) - currentText.width / 2;
    double textOffsetY = comp.position.dy + math.sin(angle + math.pi/2) * (cy+15) - currentText.height / 2;
    
    currentText.paint(canvas, Offset(textOffsetX, textOffsetY));
  }
}