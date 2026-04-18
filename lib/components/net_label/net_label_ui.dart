import 'package:flutter/material.dart';
import '../base/symbol_renderer.dart';
import 'net_label.dart';

class NetLabelSymbol implements SymbolRenderer<NetLabel> {

@override
  void drawSymbol(Canvas canvas, Size size, Paint paint) {
    final fillPaint = paint..style = PaintingStyle.fill; 
    final path = Path()
      ..moveTo(10,0)
      ..lineTo(15, -10)..lineTo(60, -10)..lineTo(60, 10)..lineTo(15, 10)..close();
    canvas.drawPath(path, fillPaint);
  }

  @override
  void drawInnerSymbol(Canvas canvas, Paint paint, NetLabel component) {
    // Disegna la linea di attacco (fuori dal Path principale per non riempirla)
    canvas.drawLine(Offset.zero, const Offset(10.5, 0), paint);

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
      tp.paint(canvas, Offset(15 + (45 - tp.width) / 2, -tp.height / 2));
    }
  }
}