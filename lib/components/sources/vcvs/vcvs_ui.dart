import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../base/symbol_renderer.dart';
import '../../../ui/widgets/component_preview.dart';
import 'vcvs.dart';

class VCVSUI extends SymbolRenderer<VCVS> {
  @override
  void drawSymbol(Canvas canvas, Size size, Paint paint) {
    final rect = Rect.fromCenter(center: Offset.zero, width: 40, height: 40);
    final path = Path()
      ..moveTo(-40, -20)
      ..lineTo(-20, -20)..lineTo(-10, -10) // +c terminal
      ..moveTo(-40, 20)
      ..lineTo(-20, 20)..lineTo(-10, 10) // -c terminal
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
  void drawInnerSymbol(Canvas canvas, Paint paint, VCVS? component) {
    final path = Path()
      ..moveTo(-5, -8)
      ..lineTo(5, -8) // +
      ..moveTo(0, -13)
      ..lineTo(0, -3)
      ..moveTo(-5, 8)
      ..lineTo(5, 8) // -
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
Widget vcvsPreview() =>
    ComponentPreview(component: VCVS(name: "Vc1", value: 10, rotation: 0));
