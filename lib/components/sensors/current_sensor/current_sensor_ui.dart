import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../../ui/widgets/component_preview.dart';
import '../../base/symbol_renderer.dart';
import 'current_sensor.dart';

class CurrentSensorUI extends SymbolRenderer<CurrentSensor> {
  @override
  void drawSymbol(Canvas canvas, Size size, Paint paint) {
    final path = Path()
      ..moveTo(0, -20)
      ..lineTo(0, -10)
      ..moveTo(0, 10)
      ..lineTo(0, 20)
      ..addRect(Rect.fromCenter(center: Offset.zero, width: 20, height: 20));
    canvas.drawPath(path, paint);
  }

  @override
  void drawInnerSymbol(Canvas canvas, Paint paint, CurrentSensor? component) {
    final path = Path()
      ..moveTo(-4, -2)
      ..lineTo(0, -6)
      ..lineTo(4, -2)
      ..moveTo(0, -6)
      ..lineTo(0, 6);

    canvas.drawPath(path, paint);
  }
}

@Preview()
Widget currentSensorPreview() =>
    ComponentPreview(component: CurrentSensor(name: "A1", rotation: 0));
