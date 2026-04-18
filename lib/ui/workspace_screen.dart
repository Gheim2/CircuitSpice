import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
// Import dei blocchi logici
import 'package:circuit_spice/config/app_mode.dart';
import 'package:circuit_spice/logic/circuit_manager.dart';
import 'package:circuit_spice/logic/interaction_controller.dart';

// Import dei componenti e della UI tramite Barrel Files
import 'package:circuit_spice/components/components.dart';
import 'package:circuit_spice/ui/circuit_painter.dart';
import 'package:circuit_spice/ui/overlays/dialogs.dart';
import 'package:circuit_spice/ui/widgets/widgets.dart';
import 'package:circuit_spice/ui/widgets/components_library.dart';


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
  bool _isLibraryOpen = false;

  final double _workspaceSize = 10000.0; 

  @override
  void initState() {
    super.initState();
    _controller = InteractionController(_manager);
    _controller.addListener(() => setState(() {})); // Riascolta i cambiamenti del controller per aggiornare la UI
    
    // Centriamo la telecamera all'avvio dell'app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screen = MediaQuery.of(context).size;
      _camController.value = Matrix4.identity()
        ..translateByVector3(Vector3(
          -(_workspaceSize / 2) + (screen.width / 2),
          -(_workspaceSize / 2) + (screen.height / 2),
          0)
        );
        setState(() {});
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
        onModeChanged: (mode) => setState(() {
          _controller.setMode(mode, spawnPos: _getCanvasCenter());
          _isLibraryOpen = false;
        }),
        onPlayPressed: () => _controller.runNetlistener(),
        isLibraryOpen: _isLibraryOpen,
        onToggleLibrary: () => setState(() {
          _isLibraryOpen = !_isLibraryOpen;
        }),

      ),
      body: Stack(
        children: [
          // --- Il Canvas, mobile con lo schermo
          SizedBox.expand(
            child: InteractiveViewer(
              transformationController: _camController,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(40.0),
              minScale: 0.1,
              maxScale: 10.0,
              panEnabled: _controller.currentMode == AppMode.select ? !_controller.isCanvasLocked : false,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildCanvasLayer(),
                  _buildContextToolbar(),
                  _buildPlacementToolbar(),
                ],
              )
            ),
          ),
          // --- UI Overlay, fisso con schermo
          _buildComponentsLibrary(), 
        ],
      ),
    );
  }

  // --- Helper di Layout ---
  Widget _buildComponentsLibrary() {
    if (!_isLibraryOpen) return const SizedBox.shrink();
    return Positioned(
      bottom: 20,
      right: 20,
      child: ComponentsLibrary(
        onComponentSelected: (mode) {
          setState(() {
            _controller.setMode(mode, spawnPos: _getCanvasCenter());
            _isLibraryOpen = false;
          });
        },
        onClose: () => setState(() => _isLibraryOpen = false),
      ),
    );
  }

  Widget _buildCanvasLayer() {
    return Listener(
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
          eraseCurrent: _controller.eraseCurrent,
          tempWireStart: _controller.tempWireStart,
          tempWireCurrent: _controller.tempWireCurrent,
          previewComponent: _controller.previewComponent,
          repaintTrigger: _renderTrigger,
        ),
      ),
    );
  }

  Widget _buildContextToolbar() {
    if (_controller.selectedComponent == null || _controller.isCanvasLocked) return const SizedBox.shrink();
    return Positioned(
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
    );
  }

  Widget _buildPlacementToolbar() {
    if (_controller.previewComponent == null) return const SizedBox.shrink();
    return Positioned(
      left: _controller.previewComponent!.position.dx - 65,
      top: _controller.previewComponent!.position.dy - 80,
      child: SafeArea(
        child: PlacementToolbar(
          onConfirm: _controller.confirmPlacement,
          onCancel: _controller.cancelPlacement,
          onRotate: _controller.rotatePreview,
        ),
      ),
    );
  }

  void _handlePointerEnd(PointerEvent event) {
    _controller.onPointerUp(event, (ElectronicComponent comp) {
        _showEditForm(comp);
      });
  }

  void _showEditForm(ElectronicComponent component) {
    showComponentEditor(
      context: context,
      component: component,
      onDelete: () => _controller.deleteSelected(),
      onRotate: () {
        bool success = _controller.manager.tryRotate(component);
        if (success) setState(() {}); // Aggiorna lo sfondo se ha successo
        return success;
      },
      onUpdate: () => setState(() {}),
    );
  }
  
  Offset _getCanvasCenter() {
    final screenSize = MediaQuery.of(context).size;
    final screenCenter = Offset(screenSize.width / 2, screenSize.height /2);
    final Matrix4 inverseMatrix = Matrix4.inverted(_camController.value);
    return MatrixUtils.transformPoint(inverseMatrix, screenCenter);
  }
}