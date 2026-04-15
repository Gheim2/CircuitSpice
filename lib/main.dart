import 'package:circuit_spice/logic/interaction_controller.dart';
import 'package:circuit_spice/models/electronic_component.dart';
import 'package:circuit_spice/ui/context_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'logic/circuit_manager.dart';
import 'ui/toolbar.dart';
import 'ui/circuit_painter.dart';
import 'ui/dialogs.dart';


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

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});
  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  late InteractionController _controller;
  final CircuitManager _manager = CircuitManager();
  final TransformationController _camController = TransformationController();
  final ValueNotifier<int> _renderTrigger = ValueNotifier<int>(0);

  final double _workspaceSize = 10000.0; 

  void _handlePointerEnd(PointerEvent event) {
    _controller.onPointerUp(event, (comp) {
      showComponentEditor(
        context: context, 
        component: comp, 
        onDelete: () {
          _manager.components.remove(comp);
          setState(() {}); // Aggiorna UI
        },
        onRotate: () => _manager.tryRotate(comp), 
        onUpdate: () => setState(() {}),
      );
    });
  }

  void _showEditForm(ElectronicComponent component) {
    showComponentEditor(
      context: context,
      component: component,
      onDelete: () {
        // Selezioniamo il componente e usiamo il metodo del controller
        _controller.selectedComponent = component;
        _controller.deleteSelected(); 
      },
      onRotate: () {
        // tryRotate restituisce un booleano, che passiamo direttamente al dialog
        bool success = _controller.manager.tryRotate(component);
        if (success) {
          setState(() {}); // Aggiorna lo sfondo se ha successo
        }
        return success;
      },
      onUpdate: () {
        // Avvisa il CustomPaint di ridisegnarsi per mostrare in tempo reale 
        // le modifiche ai nomi e ai valori sullo schermo
        setState(() {});
      },
    );
  }
  
  @override
  void initState() {
    super.initState();
    _controller = InteractionController(_manager);
    _controller.addListener(() => setState(() {})); // Riascolta i cambiamenti del controller per aggiornare la UI
    
    // Centriamo la telecamera esattamente al centro del foglio all'avvio dell'app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      
      _camController.value = Matrix4.identity()
        ..translateByVector3(Vector3(
          -(_workspaceSize / 2) + (screenWidth / 2),
          -(_workspaceSize / 2) + (screenHeight / 2),
          0)
        );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _camController.dispose();
    _renderTrigger.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: WorkspaceToolbar(
        currentMode: _controller.currentMode,
        onModeChanged: (mode) => setState(() => _controller.setMode(mode)),
        onPlayPressed: () => _controller.runNetlistener(),
      ),
      body: InteractiveViewer(
        transformationController: _camController,
        constrained: false,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        minScale: 0.1,
        maxScale: 10.0,
        panEnabled: _controller.currentMode == AppMode.select ? !_controller.isCanvasLocked : false,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: _controller.onPointerDown,
                onPointerMove: _controller.onPointerMove,
                onPointerUp: _handlePointerEnd,
                onPointerCancel: _handlePointerEnd,
                child: CustomPaint(
                  size: Size(_workspaceSize, _workspaceSize),
                  painter: CircuitPainter(
                    components: _manager.components,
                    wires: _manager.wires,
                    nodeVoltages: _manager.engine?.nodeVoltages ?? {}, // Passa le tensioni dei nodi al painter
                    componentCurrents: _manager.engine?.componentCurrents ?? {}, // Passa le correnti dei componenti al painter
                    eraseStart: _controller.eraseStart,
                    eraseCurrent: _controller.eraseCurrent,
                    tempWireStart: _controller.tempWireStart,
                    tempWireCurrent: _controller.tempWireCurrent,
                    repaintTrigger: _renderTrigger,
                  ),
                ),
              ),
              if (_controller.selectedComponent != null && !_controller.isCanvasLocked)
                Positioned(
                  left: _controller.selectedComponent!.position.dx - 80,
                  top: _controller.selectedComponent!.position.dy - 65,
                  child: ContextToolbar(
                    onEdit: () => _showEditForm(_controller.selectedComponent!),
                    onCopy: () {
                    _controller.copySelected();
                    setState(() {}); // Aggiorniamo l'interfaccia dopo l'azione
                    },
                    onRotate: () {
                      _controller.rotateSelected();
                      setState(() {});
                    },
                    onDelete: () {
                      _controller.deleteSelected();
                      setState(() {});
                    },
                  ),
                ),
            ],
          )
        ),
      );
  }
}


