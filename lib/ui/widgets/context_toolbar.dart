import 'package:flutter/material.dart';
import 'widget_utilities.dart';

class ContextToolbar extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onCopy;
  final VoidCallback onRotate;
  final VoidCallback onDelete;

  const ContextToolbar({
    super.key,
    required this.onEdit,
    required this.onCopy,
    required this.onRotate,
    required this.onDelete,
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
            buildBtn(Icons.edit, onEdit, "Edit"),
            buildBtn(Icons.copy, onCopy, "Copy"),
            buildBtn(Icons.rotate_right, onRotate, "Rotate"),
            buildBtn(Icons.delete, onDelete, "Delete"),
          ],
        )
      ),
    );
  }
}