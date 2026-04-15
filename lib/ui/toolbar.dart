import 'package:circuit_spice/models/current_source.dart';
import 'package:circuit_spice/models/electronic_component.dart';
import 'package:circuit_spice/models/ground.dart';
import 'package:circuit_spice/models/net_label.dart';
import 'package:circuit_spice/models/v_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../ui/component_icon.dart';
import '../models/resistor.dart';

// Modalità del programma: selezione, posizionamento, ecc.
enum AppMode { select, erase, placeResistor, placeVoltage, placeCurrent, drawWire, placeGround, placeLabelNet }

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
          _buildBtn(Icons.ads_click, AppMode.select, 'Select'),
          _buildBtn(Icons.delete, AppMode.erase, 'Erase', activeColor : Colors.redAccent),
          _buildBtn(Icons.linear_scale, AppMode.drawWire, 'Wire'),
          _buildCompBtn(Resistor(position: Offset.zero), AppMode.placeResistor, 'Resistor'),
          _buildCompBtn(VoltageSource(position: Offset.zero), AppMode.placeVoltage, 'Voltage'),
          _buildCompBtn(CurrentSource(position: Offset.zero), AppMode.placeCurrent, 'Current'),
          _buildCompBtn(Ground(position: Offset.zero), AppMode.placeGround, 'Ground', customScale: 1.8, iconOffset: Offset(0, -10)),
          _buildCompBtn(NetLabel(position: Offset.zero), AppMode.placeLabelNet, 'Net Label'),
          IconButton(icon: const Icon(Icons.play_arrow_rounded, color: Colors.green),
            tooltip: 'Simulate',
            onPressed: onPlayPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildCompBtn(
    ElectronicComponent component, 
    AppMode mode, String tooltip, 
    {Color activeColor = Colors.orangeAccent,
    double customScale = 1.0,
    Offset iconOffset = Offset.zero,
    }) 
    {
    final isActive = currentMode == mode;
    return IconButton(
      icon: ComponentIcon(
        component: component, 
        color: isActive ? activeColor : Colors.white,
        customScale: customScale,
        iconOffset: iconOffset,
      ),
      tooltip: tooltip,
      onPressed: () => onModeChanged(mode),
    );
  }

  Widget _buildBtn(IconData icon, AppMode mode, String tooltip, {Color activeColor = Colors.orangeAccent}) {
    final isActive = currentMode == mode;
    return IconButton(
      icon: Icon(icon, color: isActive ? activeColor : Colors.white),
      tooltip: tooltip,
      onPressed: () => onModeChanged(mode),
    );
  }

  Widget _buildSvgBtn(String assetPath, AppMode mode, String tooltip) {
    final isActive = currentMode == mode;
    return IconButton(
      icon: SvgPicture.asset(
        assetPath, 
        width: 24, 
        height: 24, 
        colorFilter: ColorFilter.mode(
          isActive ? Colors.orangeAccent : Colors.white, 
          BlendMode.srcIn
        ),
      ),
      tooltip: tooltip,
      onPressed: () => onModeChanged(mode),
    );
  }

}