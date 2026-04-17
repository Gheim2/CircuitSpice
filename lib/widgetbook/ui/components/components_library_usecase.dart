import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import '../../../ui/widgets/components_library.dart';
// ignore_for_file: avoid_print

@widgetbook.UseCase(
  name: 'Standard Components Library',
  type: ComponentsLibrary,
)
Widget buildComponentsLibraryUseCase(BuildContext context) {
  return Center(
    child: ComponentsLibrary(),
  );
}