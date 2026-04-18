import 'package:flutter/material.dart';
import 'app_mode.dart';
import '../components/components.dart';
// import '../ui/renderers/component_renderer.dart';

class ComponentManifest {
  final Type modelType;                      // Il tipo di classe
  final AppMode mode;                        // La modalità associata
  final String label;                        // Il nome nel menu
  final ElectronicComponent Function(int) builder; // Come si costruisce
  final SymbolRenderer renderer;             // Come si disegna
  final double iconScale;                    // Modifiche grafiche per l'icona
  final Offset iconOffset;

  const ComponentManifest({
    required this.modelType,
    required this.mode,
    required this.label,
    required this.builder,
    required this.renderer,
    this.iconScale = 1.0,
    this.iconOffset = Offset.zero,
  });
}

// AGGIUNGI COMPONENTE
final List<ComponentManifest> globalComponentRegistry = [
  ComponentManifest(
    modelType: Resistor,
    mode: AppMode.placeResistor,
    label: 'Resistor',
    builder: (id) => Resistor(name: 'R$id', value: 1000),
    renderer: ResistorSymbol(),
  ),
  ComponentManifest(
    modelType: VoltageSource,
    mode: AppMode.placeVoltage,
    label: 'V-Source',
    builder: (id) => VoltageSource(name: 'V$id', value: 5.0),
    renderer: VSourceSymbol(),
  ),
  ComponentManifest(
    modelType: CurrentSource,
    mode: AppMode.placeCurrent,
    label: 'I-Source',
    builder: (id) => CurrentSource(name: 'I$id', value: 1.0),
    renderer: CurrentSourceSymbol(),
  ),
  ComponentManifest(
    modelType: Ground,
    mode: AppMode.placeGround,
    label: 'Ground',
    builder: (id) => Ground(),
    renderer: GroundSymbol(),
  ),
  ComponentManifest(
    modelType: NetLabel,
    mode: AppMode.placeLabelNet,
    label: 'Net Label',
    builder: (id) => NetLabel(name: 'Net$id'),
    renderer: NetLabelSymbol(),
    iconOffset: const Offset(-30, 0),
  ),
];