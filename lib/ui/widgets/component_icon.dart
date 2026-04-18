import 'package:flutter/material.dart';
import 'package:circuit_spice/ui/renderers/component_renderer.dart';
import 'package:circuit_spice/config/app_mode.dart';

class ComponentIcon extends StatelessWidget {
  final AppMode mode;
  final double size;
  final Color color;

  final double customScale;
  final Offset iconOffset;

  const ComponentIcon({
    super.key,
    required this.mode,
    this.size = 40.0, // Dimensione standard per un'icona da toolbar
    this.color = Colors.white,
    this.customScale = 1.0, // Fattore di scala personalizzato
    this.iconOffset = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _IconPainter(mode, color, customScale, iconOffset),
      ),
    );
  }
}

class _IconPainter extends CustomPainter {
  final AppMode mode;
  final Color color;
  final double customScale;
  final Offset iconOffset;

  _IconPainter(this.mode, this.color, this.customScale, this.iconOffset);

  @override
  void paint(Canvas canvas, Size size) {
    final renderer = ComponentRenderer.getRendererForMode(mode);
    if (renderer == null) return;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    // Dividiamo la dimensione dell'icona per 80 per trovare il fattore di riduzione.
    double scale = size.width / 80.0 * customScale;
    canvas.scale(scale);
    canvas.translate(iconOffset.dx, iconOffset.dy);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      // Dividiamo lo spessore per la scala sennò resta troppo spessa
      ..strokeWidth = 1.5 / scale 
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    renderer.drawSymbol(canvas, size, paint);
    canvas.restore();
    // component.drawSymbol(canvas, paint);
  }

  @override
  bool shouldRepaint(covariant _IconPainter oldDelegate) {
    return oldDelegate.color != color; // Ridisegna solo se cambia colore (es. hover)
  }
}