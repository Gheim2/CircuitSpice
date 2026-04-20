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
  }
}