import 'package:flutter/material.dart';
import '../../config/app_mode.dart';
import 'widget_utilities.dart';

class WorkspaceToolbar extends StatelessWidget {
  final AppMode currentMode;
  final ValueChanged<AppMode> onModeChanged;
  final VoidCallback onPlayPressed;
  final VoidCallback onToggleLibrary; 
  final bool isLibraryOpen;

  const WorkspaceToolbar({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    required this.onPlayPressed,
    required this.onToggleLibrary,
    required this.isLibraryOpen,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.grey[850],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildBtn(Icons.ads_click, () => onModeChanged(AppMode.select), 'Select', isActive: _isActive(AppMode.select)),
          buildBtn(Icons.delete, () => onModeChanged(AppMode.erase), 'Erase', activeColor: Colors.redAccent, isActive: _isActive(AppMode.erase)),
          buildBtn(Icons.linear_scale, () => onModeChanged(AppMode.drawWire), 'Wire', isActive: _isActive(AppMode.drawWire)),
          buildModeBtn(AppMode.placeResistor, () => onModeChanged(AppMode.placeResistor), 'Resistor', isActive: _isActive(AppMode.placeResistor)),
          buildModeBtn(AppMode.placeVoltage, () => onModeChanged(AppMode.placeVoltage), 'Voltage', isActive: _isActive(AppMode.placeVoltage)),
          buildModeBtn(AppMode.placeCurrent, () => onModeChanged(AppMode.placeCurrent), 'Current', isActive: _isActive(AppMode.placeCurrent)),
          buildModeBtn(AppMode.placeGround, () => onModeChanged(AppMode.placeGround), 'Ground', customScale: 1.8, iconOffset: Offset(0, -10), isActive: _isActive(AppMode.placeGround)),
          buildModeBtn(AppMode.placeLabelNet, () => onModeChanged(AppMode.placeLabelNet), 'Net Label', iconOffset: Offset(-35, 0), isActive: _isActive(AppMode.placeLabelNet)),
          separator(),
          buildBtn(Icons.category, onToggleLibrary, 'Library', activeColor: Colors.blueAccent, isActive: isLibraryOpen),
          buildBtn(Icons.play_arrow_rounded, onPlayPressed, 'Simulate', baseColor: Colors.green),
        ],
      ),
    );
  }

  bool _isActive(AppMode mode) => currentMode == mode;

}