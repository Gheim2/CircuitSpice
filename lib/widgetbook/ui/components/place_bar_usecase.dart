import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import '../../../ui/widgets/placement_toolbar.dart';

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