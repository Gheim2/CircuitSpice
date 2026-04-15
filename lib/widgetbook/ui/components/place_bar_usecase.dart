import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import '../../../ui/widgets/placement_toolbar.dart';
// ignore_for_file: avoid_print
@widgetbook.UseCase(
  name: 'Place Menu',
  type: PlacementToolbar,
)
Widget placeBarUseCase(BuildContext context) {
  return Center(
    child: PlacementToolbar(
      onCancel: () => print('Cancel pressed'),
      onConfirm: () => print('Confirm pressed'),
      onRotate: () => print('Rotate pressed'),
    ),
  );
}