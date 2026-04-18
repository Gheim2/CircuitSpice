import 'package:circuit_spice/config/app_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:circuit_spice/components/core.dart';
import 'component_icon.dart';
// Da importare per disegnare le toolbar

Widget buildModeBtn(
    AppMode mode, 
    VoidCallback callback, String tooltip, 
    {Color activeColor = Colors.orangeAccent,
    double customScale = 1.0,
    Offset iconOffset = Offset.zero,
    bool isActive = false,
    }) 
    {
    return IconButton(
      icon: ComponentIcon(
        mode: mode, 
        color: isActive ? activeColor : Colors.white,
        customScale: customScale,
        iconOffset: iconOffset,
      ),
      tooltip: tooltip,
      onPressed: callback,
    );
  }

  Widget buildBtn(IconData icon, VoidCallback callback, String tooltip, {Color baseColor = Colors.white, Color activeColor = Colors.orangeAccent, bool isActive = false}) {
    return IconButton(
      icon: Icon(icon, color: isActive ? activeColor : baseColor),
      tooltip: tooltip,
      onPressed: callback,
    );
  }


  Widget buildSvgBtn(String assetPath, VoidCallback callback, String tooltip, {Color activeColor = Colors.orangeAccent, bool isActive = false}) {
    return IconButton(
      icon: SvgPicture.asset(
        assetPath, 
        width: 24, 
        height: 24, 
        colorFilter: ColorFilter.mode(
          isActive ? activeColor : Colors.white, 
          BlendMode.srcIn
        ),
      ),
      tooltip: tooltip,
      onPressed: callback,
    );
  }

  Widget separator() {
    return Container(
      width: 1, 
      height: 30, 
      color: Colors.white24, // Separatore visivo opzionale
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }