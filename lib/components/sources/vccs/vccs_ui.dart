import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../base/symbol_renderer.dart';
import '../../../ui/widgets/component_preview.dart';
import 'vccs.dart';

class VCCSUI extends SymbolRenderer<VCCS> {
  @override
  void drawSymbol(Canvas canvas, Size size, Paint paint) {
    final rect = Rect.fromCenter(center: Offset.zero, width: 40, height: 40);
    final path = Path()
      ..moveTo(-40, -20)
      ..lineTo(-20, -20)..lineTo(-10, -10) // ^ Out terminal
      ..moveTo(-40, 20)
      ..lineTo(-20, 20)..lineTo(-10, 10) // | In terminal
      ..moveTo(0, -40)
      ..lineTo(0, -20) // + terminal |
      ..moveTo(0, 40)
      ..lineTo(0, 20) // - terminal |
      ..moveTo(0, rect.top)
      ..lineTo(rect.right, 0) // Rombo
      ..lineTo(0, rect.bottom)
      ..lineTo(rect.left, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  void drawInnerSymbol(Canvas canvas, Paint paint, VCCS? component) {
    final path = Path()
      ..moveTo(-5, -5)..lineTo(0, -10)..lineTo(5, -5) // ^ Arrow Pointer
      ..moveTo(0, 10)..lineTo(0, -10) // | Arrow Body
      ..moveTo(-32, -8)
      ..lineTo(-24, -8) // + pilot
      ..moveTo(-28, -12)
      ..lineTo(-28, -4)
      ..moveTo(-32, 8)
      ..lineTo(-24, 8); // - pilot

    canvas.drawPath(path, paint);
  }
}

@Preview()
Widget vccsPreview() =>
    ComponentPreview(component: VCCS(name: "Ic1", value: 10, rotation: 0));
