import 'package:circuit_spice/config/app_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'component_icon.dart';

Widget buildModeBtn(
  AppMode mode,
  VoidCallback callback,
  String tooltip, {
  Color activeColor = Colors.orangeAccent,
  double customScale = 1.0,
  Offset iconOffset = Offset.zero,
  bool isActive = false,
}) {
  return _buildUnifiedButtonBox(
    child: ComponentIcon(
      mode: mode,
      color: isActive ? activeColor : Colors.white,
      customScale: customScale,
      iconOffset: iconOffset,
    ), 
    onTap: callback, 
    tooltip: tooltip
  );
}

Widget buildBtn(
  IconData icon,
  VoidCallback callback,
  String tooltip, {
  Color baseColor = Colors.white,
  Color activeColor = Colors.orangeAccent,
  bool isActive = false,
}) {
  return _buildUnifiedButtonBox(
    child: Icon(
      icon,
      color: isActive ? activeColor : baseColor,
      size: 24,
    ), 
    onTap: callback, 
    tooltip: tooltip
    );
}

Widget buildSvgBtn(
  String assetPath,
  VoidCallback callback,
  String tooltip, {
  Color activeColor = Colors.orangeAccent,
  bool isActive = false,
}) {
  return IconButton(
    icon: SvgPicture.asset(
      assetPath,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        isActive ? activeColor : Colors.white,
        BlendMode.srcIn,
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

Widget _buildUnifiedButtonBox({
  required Widget child,
  required VoidCallback onTap,
  required String tooltip,
}) {
  return Tooltip(
    message: tooltip,
    child: SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(), // Forza la bolla a essere un cerchio perfetto
        clipBehavior: Clip.hardEdge, // Taglia qualsiasi sbavatura visiva
        child: InkWell(
          onTap: onTap,
          // L'InkWell riempirà esattamente i 48x48 pixel circolari
          child: Center(
            child: child, // L'icona viene centrata perfettamente
          ),
        ),
      ),
    ),
  );
}
