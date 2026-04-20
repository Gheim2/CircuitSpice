import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../ui/widgets/component_preview.dart';
import '../base/symbol_renderer.dart';
import 'net_label.dart';

class NetLabelUI extends SymbolRenderer<NetLabel> {

  @override
  Color get baseColor => Colors.purpleAccent;

  @override
  void drawSymbol(Canvas canvas, Size size, Paint paint) {
    canvas.drawLine(Offset.zero, const Offset(10.5, 0), paint);
    final fillPaint = paint..style = PaintingStyle.fill; 
    final path = Path()
      ..moveTo(10,0)
      ..lineTo(15, -10)..lineTo(60, -10)..lineTo(60, 10)..lineTo(15, 10)..close();
    canvas.drawPath(path, fillPaint);
  }

  @override
  void drawInnerSymbol(Canvas canvas, Paint paint, NetLabel? component) {
    if (component == null) return;
    // Disegna il nome dentro il componente
    if (component.name.isNotEmpty) {
      Color textColor = paint.color == Colors.white ? Colors.black : Colors.white;
      final tp = TextPainter(
        text: TextSpan(
          text: component.name,
          style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, height: 1.0),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final centerX = 15.0 + (45.0 / 2);
      final centerY = 0.0;
      canvas.save();
      canvas.translate(centerX, centerY);
      double absAngle = component.rotation % 360;
      // To avoid upside-down text
      if (absAngle > 90 && absAngle <= 270) {
        canvas.rotate(math.pi); // Ruota di 180 gradi
      }
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }
}

@Preview()
Widget netLabelPreview() =>
    ComponentPreview(component: NetLabel(name: "Net1", rotation: 0));
