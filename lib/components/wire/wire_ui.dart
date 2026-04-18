import 'wire.dart';
import 'package:flutter/material.dart';
import '../../ui/renderers/drawing_utils.dart';

class WireRenderer {
  static void draw(
    Canvas canvas, 
    List<Wire> wires, 
    Map<int, double> nodeVoltages,
    Set<int> drawnLabelNets,
    Color Function(int) getColorFn,
  ) {
    Map <int, Wire> longestWirePerNet = {};
    for (var wire in wires) {
      final netColor = getColorFn(wire.netId);
      // Disegna il filo
      final netPaint = Paint()
        ..color = netColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(wire.start, wire.end, netPaint);
      if (wire.netId != -1) {
        double currentLength = wire.length;
        if (!longestWirePerNet.containsKey(wire.netId)) {
          longestWirePerNet[wire.netId] = wire;
        } else {
          Wire previousLongest = longestWirePerNet[wire.netId]!;
          double previousLength = previousLongest.length;
          if (currentLength > previousLength) {
            longestWirePerNet[wire.netId] = wire;
          }
        }
        drawnLabelNets.add(wire.netId);
      }
    }

    // Disegna le etichette solo sui fili più lunghi di ogni net
    longestWirePerNet.forEach((netId, wire) {
      if (nodeVoltages.containsKey(netId)) {
        double? voltage = nodeVoltages[netId];
        DrawingUtils.drawNetLabel(
          canvas: canvas,
          center: wire.getMidpoint(),
          netId: netId,
          color: getColorFn(netId),
          voltage: voltage,
        );
      }
    });
  }

  // Disegna filo fantasma mentre disegni
  static void drawTempWire(Canvas canvas, Offset start, Offset current) {
    final tempPaint = Paint()
      ..color = Colors.white70
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, current, tempPaint);
  }
}