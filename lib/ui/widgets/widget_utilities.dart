import 'package:circuit_spice/models/electronic_component.dart';
import 'package:circuit_spice/ui/component_icon.dart';
import 'package:flutter/material.dart';
// Da importare per disegnare le toolbar

Widget buildCompBtn(
    ElectronicComponent component, 
    VoidCallback callback, String tooltip, 
    {Color activeColor = Colors.orangeAccent,
    double customScale = 1.0,
    Offset iconOffset = Offset.zero,
    bool isActive = false,
    }) 
    {
    return IconButton(
      icon: ComponentIcon(
        component: component, 
        color: isActive ? activeColor : Colors.white,
        customScale: customScale,
        iconOffset: iconOffset,
      ),
      tooltip: tooltip,
      onPressed: callback,
    );
  }

  Widget buildBtn(IconData icon, VoidCallback callback, String tooltip, {Color activeColor = Colors.orangeAccent, bool isActive = false}) {
    return IconButton(
      icon: Icon(icon, color: isActive ? activeColor : Colors.white),
      tooltip: tooltip,
      onPressed: callback,
    );
  }

  // Widget _buildSvgBtn(String assetPath, VoidCallback callback, String tooltip, {Color activeColor = Colors.orangeAccent, bool isActive = false}) {
  //   return IconButton(
  //     icon: SvgPicture.asset(
  //       assetPath, 
  //       width: 24, 
  //       height: 24, 
  //       colorFilter: ColorFilter.mode(
  //         isActive ? activeColor : Colors.white, 
  //         BlendMode.srcIn
  //       ),
  //     ),
  //     tooltip: tooltip,
  //     onPressed: callback,
  //   );
  // }