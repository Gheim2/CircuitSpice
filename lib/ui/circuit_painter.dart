import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:circuit_spice/ui/renderers/grid_renderer.dart';
import 'renderers/component_renderer.dart';
import 'package:circuit_spice/components/components.dart';
import 'package:circuit_spice/config/app_config.dart';

class CircuitPainter extends CustomPainter {
  final List<ElectronicComponent> components;
  final List<Wire> wires;
  final Map<int, double> nodeVoltages; // Mappa netId -> tensione
  final Map<ElectronicComponent, double> componentCurrents; // Mappa componente -> corrente
  
  // final Offset? eraseStart;
  final Offset? eraseCurrent;
  final Offset? tempWireStart;
  final Offset? tempWireCurrent;

  final ElectronicComponent? previewComponent;

  final ValueNotifier<int> repaintTrigger; 

  CircuitPainter({
    required this.components,
    required this.wires,
    this.nodeVoltages = const {}, 
    this.componentCurrents = const {}, 
    this.eraseCurrent,
    this.tempWireStart,
    this.tempWireCurrent, 
    this.previewComponent,
    required this.repaintTrigger
  }) : super(repaint: repaintTrigger);

  Color _getNetColor(int netId) {
    if (netId < 0) return Colors.greenAccent; // Filo non connesso
    if (netId == 0) return Colors.grey; // Net di massa (Ground)
    final hue = (netId * 137) % 360; // Distribuisce i colori in modo pseudo-casuale
    return HSVColor.fromAHSV(1.0, hue.toDouble(), 0.6, 0.8).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    Set<int> drawnLabelNets = {}; // Tiene traccia dei netId già etichettati
    _drawWires(canvas, drawnLabelNets);
    _drawComponents(canvas, drawnLabelNets); // Ora usiamo la versione riattivata
    _drawPreview(canvas);
  }
  
  void _drawGrid(Canvas canvas, Size size) {
    GridRenderer.draw(canvas, size, AppConfig.gridSpacing, color: Colors.grey.withValues(alpha: 0.2));
  }

  void _drawWires(Canvas canvas, Set<int> drawnLabelNets) {
    WireRenderer.draw(canvas, wires, nodeVoltages, drawnLabelNets, _getNetColor);
    if (tempWireStart != null && tempWireCurrent != null) {
      WireRenderer.drawTempWire(canvas, tempWireStart!, tempWireCurrent!);
    }
  }

  void _drawComponents(Canvas canvas, Set<int> drawnLabelNets) {
    // DEBUG COLLISIONI
    if (kDebugMode) {
      final debugPaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      for (var component in components) {
        canvas.drawRect(component.collisionBox, debugPaint);
      }
    }

    for (var comp in components) {
      // 1. DELEGAZIONE: Disegniamo la grafica del componente tramite il nuovo Renderer
      ComponentRenderer.draw(
        canvas, 
        comp, 
      );

      // 2. LOGICA NODI: Sovrascriviamo i pin con i colori delle tue Net
      var positions = comp.globalNodePositions;
      for (int i = 0; i < positions.length; i++) {
        int? netId = comp.pinNets[i];
        if (netId != null && netId != -1) {
          final nodePaint = Paint()
            ..color = _getNetColor(netId)
            ..style = PaintingStyle.fill;
          // Disegna un pallino colorato sopra il nodo
          canvas.drawCircle(positions[i], 5.0, nodePaint); 

          // 3. LOGICA ETICHETTE MANCANTI: Se non c'era un filo per questa net, mettiamo il testo
          if(!drawnLabelNets.contains(netId)) {
            String label = (netId == 0) ? 'GND' : 'Net $netId';
            if (nodeVoltages.containsKey(netId)) {
              label += '\n${nodeVoltages[netId]!.toStringAsFixed(3)} V';
            }
            final textPainter = TextPainter(
              text: TextSpan(
                text: label,
                style: TextStyle(color: _getNetColor(netId), fontSize: 12, fontWeight: FontWeight.bold, shadows: const [
                  Shadow(
                    blurRadius: 3.0,
                    color: Colors.black87,
                    offset: Offset(1, 1),
                  ),
                ]),
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
            );
            textPainter.layout();
            textPainter.paint(canvas, positions[i] - Offset(textPainter.width / 2, textPainter.height + 8));
          }
        }
      }
    }
    for (var comp in components) {
      final current = componentCurrents[comp];
      if (current != null) {
        ComponentRenderer.drawCurrentArrow(canvas, comp, current);
      }
    }
  }
    
  void _drawPreview(Canvas canvas) {
    if (eraseCurrent != null) {
      final cutPaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.5)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(eraseCurrent!, 6, cutPaint..style = PaintingStyle.fill);
    }

    if (previewComponent != null) {
      final ghostPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeJoin = StrokeJoin.round
        ..blendMode = BlendMode.plus;
      ComponentRenderer.draw(
        canvas, 
        previewComponent!, 
        compPaint: ghostPaint,
      );
    }
  }
    
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}