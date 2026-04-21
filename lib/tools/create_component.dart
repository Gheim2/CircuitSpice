import 'dart:io';

void main(List<String> args) {
  if (args.length < 3) {
    print('❌ Errore: Parametri mancanti.');
    return;
  }

  final className = args[0]; // es. CurrentSensor
  final fileName = args[1];  // es. current_sensor
  final category = args[2];  // es. sensors

  // --- PERCORSI DINAMICI ---
  // Ora la cartella viene creata dinamicamente in base alla categoria scelta!
  final componentDir = Directory('lib/components/$category/$fileName');
  final coreFile = File('lib/components/core.dart');
  final componentsFile = File('lib/components/components.dart');
  final registryFile = File('lib/config/component_registry.dart');
  final appModeFile = File('lib/config/app_mode.dart');

  // 1. CREA LA CARTELLA (es. lib/components/sensors/current_sensor/)
  if (!componentDir.existsSync()) {
    componentDir.createSync(recursive: true);
  }

  // 2. CREA IL FILE DELLA LOGICA (.dart)
  final logicFile = File('${componentDir.path}/$fileName.dart');
  logicFile.writeAsStringSync('''
import 'package:flutter/material.dart';
import '../../../../logic/mna_context.dart'; // Aggiustato il path relativo
import '../../base/electronic_component.dart';
import '../../base/node.dart';

class $className extends ElectronicComponent {
  $className({super.position = Offset.zero, super.name = '', super.rotation = 0}) : super(value: 0.0);

  @override
  String get prefix => '${className.substring(0, 1)}';
  @override
  String get unit => '';

  @override
  ElectronicComponent clone(Offset newPosition) {
    return $className(position: newPosition, name: name, rotation: rotation);
  }

  @override
  List<ComponentNode> get nodes => [];

  @override
  Rect get baseCollisionRect => Rect.fromCenter(center: Offset.zero, width: 40, height: 40);

  @override
  void stamp(MNAContext ctx) {}
}
''');

  // 3. CREA IL FILE DELLA UI (_ui.dart)
  final uiFile = File('${componentDir.path}/${fileName}_ui.dart');
  uiFile.writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../../../ui/widgets/component_preview.dart'; // Aggiustato il path relativo
import '../../base/symbol_renderer.dart';
import '$fileName.dart';

class ${className}UI extends SymbolRenderer<$className> {
  @override
  void drawSymbol(Canvas canvas, Size size, Paint paint) {
    // TODO: Draw logic
  }
}

@Preview()
Widget ${fileName}Preview() =>
    ComponentPreview(component: $className(name: "Test", rotation: 0));
''');

  // 4. AGGIUNGI L'EXPORT IN CORE E COMPONENTS (Includendo la sottocartella!)
  _appendToFile(coreFile, "export '$category/$fileName/$fileName.dart';\n");
  _appendToFile(componentsFile, "export '$category/$fileName/${fileName}_ui.dart';\n");

  // 5. AGGIUNGI L'APP MODE
  _insertAppMode(appModeFile, 'place$className');

  // 6. INIETTA NEL REGISTRY
  _injectIntoRegistry(registryFile, className);

  print('✅ Componente $className creato in components/$category/$fileName/');
}

// ... le funzioni _appendToFile, _insertAppMode e _injectIntoRegistry rimangono IDENTICHE a prima ...
void _appendToFile(File file, String content) {
  if (file.existsSync() && !file.readAsStringSync().contains(content.trim())) {
    file.writeAsStringSync(file.readAsStringSync() + content);
  }
}

void _insertAppMode(File file, String modeName) {
  if (file.existsSync() && !file.readAsStringSync().contains(modeName)) {
    file.writeAsStringSync(file.readAsStringSync().replaceFirst('}', '  $modeName,\n}'));
  }
}

void _injectIntoRegistry(File file, String className) {
  if (!file.existsSync()) return;
  String content = file.readAsStringSync();
  String manifest = '''
  ComponentManifest(
    modelType: $className,
    mode: AppMode.place$className,
    label: '$className',
    builder: (id) => $className(name: '\${$className().prefix}\$id'),
    renderer: ${className}UI(),
  ),
''';
  if (!content.contains(className)) {
    file.writeAsStringSync(content.replaceFirst('];', '$manifest];'));
  }
}