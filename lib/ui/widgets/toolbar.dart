import 'package:circuit_spice/models/current_source.dart';
import 'package:circuit_spice/models/ground.dart';
import 'package:circuit_spice/models/net_label.dart';
import 'package:circuit_spice/models/v_source.dart';
import 'package:flutter/material.dart';
import '../../models/resistor.dart';
import '../../config/app_mode.dart';
import 'widget_utilities.dart';

class WorkspaceToolbar extends StatelessWidget {
  final AppMode currentMode;
  final ValueChanged<AppMode> onModeChanged;
  final VoidCallback onPlayPressed;

  const WorkspaceToolbar({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    required this.onPlayPressed,
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
          buildCompBtn(Resistor(position: Offset.zero), () => onModeChanged(AppMode.placeResistor), 'Resistor', isActive: _isActive(AppMode.placeResistor)),
          buildCompBtn(VoltageSource(position: Offset.zero), () => onModeChanged(AppMode.placeVoltage), 'Voltage', isActive: _isActive(AppMode.placeVoltage)),
          buildCompBtn(CurrentSource(position: Offset.zero), () => onModeChanged(AppMode.placeCurrent), 'Current', isActive: _isActive(AppMode.placeCurrent)),
          buildCompBtn(Ground(position: Offset.zero), () => onModeChanged(AppMode.placeGround), 'Ground', customScale: 1.8, iconOffset: Offset(0, -10), isActive: _isActive(AppMode.placeGround)),
          buildCompBtn(NetLabel(position: Offset.zero), () => onModeChanged(AppMode.placeLabelNet), 'Net Label', iconOffset: Offset(-35, 0), isActive: _isActive(AppMode.placeLabelNet)),
          IconButton(icon: const Icon(Icons.play_arrow_rounded, color: Colors.green),
            tooltip: 'Simulate',
            onPressed: onPlayPressed,
          ),
        ],
      ),
    );
  }

  bool _isActive(AppMode mode) => currentMode == mode;

}