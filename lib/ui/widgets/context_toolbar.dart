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

  // Widget _buildBtn(IconData icon, VoidCallback callback, String tooltip) {
  //   return IconButton(
  //     icon: Icon(icon, color: Colors.white),
  //     tooltip: tooltip,
  //     onPressed: callback,
  //   );
  // }

  // Widget _buildCompBtn(
  //   ElectronicComponent component, 
  //   VoidCallback callback, String tooltip, 
  //   {Color activeColor = Colors.orangeAccent,
  //   double customScale = 1.0,
  //   Offset iconOffset = Offset.zero,
  //   }) 
  //   {
  //   return IconButton(
  //     icon: ComponentIcon(
  //       component: component, 
  //       color: Colors.white,
  //       customScale: customScale,
  //       iconOffset: iconOffset,
  //     ),
  //     tooltip: tooltip,
  //     onPressed: callback,
  //   );
  // }


  // Widget _buildSvgBtn(String assetPath, VoidCallback callback, String tooltip) {
  //   return IconButton(
  //     icon: SvgPicture.asset(
  //       assetPath, 
  //       width: 24, 
  //       height: 24, 
  //       colorFilter: ColorFilter.mode(
  //         Colors.white, 
  //         BlendMode.srcIn
  //       ),
  //     ),
  //     tooltip: tooltip,
  //     onPressed: callback,
  //   );
  // }

}