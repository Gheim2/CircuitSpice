import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// Questo file verrà generato da build_runner usando dart run build_runner build --delete-conflicting-outputs
import 'widgetbook.directories.g.dart';

void main() {
  runApp(const WidgetbookApp());
}

@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        ViewportAddon([
          IosViewports.iPad,
          IosViewports.iPhone13,
          WindowsViewports.desktop,
          AndroidViewports.samsungGalaxyS20  
        ]),
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Dark', data: ThemeData.dark()),
            WidgetbookTheme(name: 'Light', data: ThemeData.light()),
          ],
        ),
      ],
    );
  }
}