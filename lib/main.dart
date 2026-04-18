import 'package:flutter/material.dart';
import 'ui/workspace_screen.dart';
void main() {
  runApp(const CircuitSimulatorApp());
}

class CircuitSimulatorApp extends StatelessWidget {
  const CircuitSimulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Circuit Spice Simulator',
      theme: ThemeData.dark(),
      home: const WorkspaceScreen(),
    );
  }
}
