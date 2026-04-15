import 'package:flutter/material.dart';
import '../models/electronic_component.dart';

class ComponentIcon extends StatelessWidget {
  final ElectronicComponent component;
  final double size;
  final Color color;
  final double customScale;
  final Offset iconOffset;

  const ComponentIcon({
    super.key,
    required this.component,
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
        painter: _ComponentIconPainter(component, color, customScale, iconOffset),
      ),
    );
  }
}

class _ComponentIconPainter extends CustomPainter {
  final ElectronicComponent component;
  final Color color;
  final double customScale;
  final Offset iconOffset;

  _ComponentIconPainter(this.component, this.color, this.customScale, this.iconOffset);

  @override
  void paint(Canvas canvas, Size size) {
    // Spostiamo l'origine al centro dell'icona
    canvas.translate(size.width / 2, size.height / 2);

    // Dividiamo la dimensione dell'icona per 80 per trovare il fattore di riduzione.
    double scale = size.width / 80.0 * customScale;
    canvas.scale(scale);
    canvas.translate(iconOffset.dx, iconOffset.dy);

    // 3. Prepariamo il pennello
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      // Dividiamo lo spessore per la scala! 
      // Altrimenti, se scaliamo del 30%, anche la linea diventa invisibile.
      ..strokeWidth = 1.5 / scale 
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // 4. Chiamiamo lo stesso identico metodo che usi per il circuito!
    component.drawSymbol(canvas, paint);
  }

  @override
  bool shouldRepaint(covariant _ComponentIconPainter oldDelegate) {
    return oldDelegate.color != color; // Ridisegna solo se cambia colore (es. hover)
  }
}