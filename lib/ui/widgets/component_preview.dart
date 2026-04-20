import 'package:flutter/material.dart';
import 'package:circuit_spice/ui/renderers/component_renderer.dart';
import 'package:circuit_spice/components/base/electronic_component.dart';

class ComponentPreview extends StatelessWidget {
  final ElectronicComponent component;
  final double size;
  final bool showLabels;

  const ComponentPreview({
    super.key,
    required this.component,
    this.size = 200.0,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFF121212), // Sfondo scuro professionale
      child: CustomPaint(
        painter: _SingleComponentPainter(component, showLabels),
      ),
    );
  }
}

class _SingleComponentPainter extends CustomPainter {
  final ElectronicComponent component;
  final bool showLabels;

  _SingleComponentPainter(this.component, this.showLabels);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Centriamo il disegno nel quadrato della preview
    canvas.translate(size.width / 2, size.height / 2);
    
    // 2. Chiamiamo il renderer ufficiale per garantire la fedeltà visiva
    ComponentRenderer.draw(
      canvas, 
      component, 
      drawLabels: showLabels
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}