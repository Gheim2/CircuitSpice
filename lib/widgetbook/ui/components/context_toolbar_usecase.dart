import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import '../../../ui/widgets/context_toolbar.dart';
// ignore_for_file: avoid_print

@widgetbook.UseCase(
  name: 'Standard Toolbar',
  type: ContextToolbar,
)
Widget buildContextToolbarUseCase(BuildContext context) {
  return Center(
    child: ContextToolbar(
      onEdit: () => print('Edit pressed'),
      onCopy: () => print('Copy pressed'),
      onRotate: () => print('Rotate pressed'),
      onDelete: () => print('Delete pressed'),
    ),
  );
}