import 'package:flutter/material.dart';
import 'widget_utilities.dart';

class PlacementToolbar extends StatelessWidget{
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final VoidCallback onRotate;

  const PlacementToolbar({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    required this.onRotate,
  });

  @override 
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(30),
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildBtn(Icons.check, onConfirm, "Confirm"),
            buildBtn(Icons.close, onCancel, "Cancel"),
            buildBtn(Icons.rotate_right, onRotate, "Rotate"),
          ],
        )
      ),
    );
  }
}