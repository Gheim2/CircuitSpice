import '../components/core.dart';
import '../config/app_mode.dart';
import '../config/component_registry.dart';

class ComponentFactory {
  static ElectronicComponent? spawn(AppMode mode, int id) {
    try {
      final manifest = globalComponentRegistry.firstWhere((m) => m.mode == mode);
      return manifest.builder(id);
    } catch (e) {
      return null;
    }
    // switch (mode) {
    //   case AppMode.placeResistor:
    //     return Resistor(name: 'R$id', value: 1000);
    //   case AppMode.placeGround:
    //     return Ground();
    //   case AppMode.placeVoltage:
    //     return VoltageSource(name: 'V$id', value: 5.0);
    //   case AppMode.placeCurrent:
    //     return CurrentSource(name: 'I$id', value: 1.0);
    //   case AppMode.placeLabelNet:
    //     return NetLabel(name: 'NET$id');
    //   default:
    //     return null;
    // }
  }
}