import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config/app_mode.dart';
import '../components/core.dart';
import 'circuit_manager.dart';

class InteractionController extends ChangeNotifier {
  final CircuitManager manager;

  // --- STATO DEL CONTROLLER ---
  AppMode currentMode = AppMode.select;
  final ValueNotifier<int> _resCounter = ValueNotifier<int>(0);
  final ValueNotifier<int> _vSourceCounter = ValueNotifier<int>(0);
  final ValueNotifier<int> _cSourceCounter = ValueNotifier<int>(0);
  final ValueNotifier<int> _labelCounter = ValueNotifier<int>(0);
  ValueNotifier<int>? _activePreviewCounter; // Per tenere traccia del contatore attivo durante il posizionamento
  DateTime? _downTime;

  // Variabili temporanee
  ElectronicComponent? draggedComponent;
  ElectronicComponent? _draggedLabelComponent;
  ElectronicComponent? selectedComponent;
  ElectronicComponent? previewComponent;
  Offset? originalPos;
  Offset? eraseCurrent;
  Offset? tempWireStart;
  Offset? tempWireCurrent;

  InteractionController(this.manager);

  bool get isCanvasLocked =>
    draggedComponent != null ||
    _draggedLabelComponent != null ||
    tempWireStart != null ||
    eraseCurrent != null ||
    previewComponent != null;

  // Metodo per cambiare modalità dalla Toolbar
  void setMode(AppMode mode, {Offset? spawnPos}) {
    currentMode = mode;
    selectedComponent?.isSelected = false; // Deseleziona il componente attualmente selezionato
    selectedComponent = null;
    previewComponent = null;
    _activePreviewCounter = null;
    _initPreviewForMode(mode, spawnPos: spawnPos);
    notifyListeners(); // Fondamentale per aggiornare le icone della toolbar
  }

  // --- GESTIONE EVENTI (SMISTAMENTO) ---

  void runNetlistener() {
    manager.generateNetList();
    notifyListeners(); 
  }

  void onPointerDown(PointerDownEvent event) {
    _downTime = DateTime.now();
    final pos = event.localPosition;
    if (previewComponent != null) {
      originalPos = previewComponent!.position;
      previewComponent!.position = manager.getSnappedPosition(pos);
      notifyListeners();
      return; 
    }

    switch (currentMode) {
      case AppMode.select: _handleSelectDown(pos); break;
      case AppMode.drawWire: _handleDrawWireDown(pos); break;
      case AppMode.erase: _handleEraseDown(pos); break;
      default: break;
    }
    notifyListeners();
  }

  void onPointerMove(PointerMoveEvent event) {
    final pos = event.localPosition;
    if (previewComponent != null) {
      previewComponent!.position = manager.getSnappedPosition(pos);
      notifyListeners();
      return;
    }
    switch (currentMode) {
      case AppMode.select: _handleSelectMove(event.localDelta); break;
      case AppMode.drawWire: _handleDrawWireMove(pos); break;
      case AppMode.erase: _handleEraseMove(pos); break;
      default: break;
    }
    notifyListeners();
  }

  void onPointerUp(PointerEvent event, Function(ElectronicComponent) onEdit) {
    final pos = event.localPosition;
    final duration = DateTime.now().difference(_downTime!);
    final dist = originalPos != null ? (pos - originalPos!).distance : 0.0;
    if (previewComponent != null) {
      if (duration.inMilliseconds < 250 && dist < 30.0 && previewComponent!.contains(pos)) {
        confirmPlacement();
        originalPos = null;
      }
      return;
    }
    switch (currentMode) {
      case AppMode.select: _handleSelectUp(); break;
      case AppMode.drawWire: _handleDrawWireUp(); break;
      case AppMode.erase: _handleEraseUp(); break;
      default: break;
    }
    notifyListeners();
  }

  // --- AZIONI DEL MENU DI ANTEPRIMA ---

  void _initPreviewForMode(AppMode mode, {Offset? spawnPos}) {
    switch (mode) {
      case AppMode.placeResistor:
        previewComponent = Resistor(name: 'R${_resCounter.value + 1}', value: 1000);
        _activePreviewCounter = _resCounter;
        break;
      case AppMode.placeGround:
        previewComponent = Ground();
        _activePreviewCounter = null;
        break;
      case AppMode.placeVoltage:
        previewComponent = VoltageSource(name: 'V${_vSourceCounter.value + 1}', value: 5.0);
        _activePreviewCounter = _vSourceCounter;
        break;
      case AppMode.placeCurrent:
        previewComponent = CurrentSource(name: 'I${_cSourceCounter.value + 1}', value: 1.0);
        _activePreviewCounter = _cSourceCounter;
        break;
      case AppMode.placeLabelNet:
        previewComponent = NetLabel();
        _activePreviewCounter = _labelCounter;
        break;
      default:
        break;
    }
    if (previewComponent != null) {
      spawnPos ??= Offset.zero;
      _handlePlaceComponent(spawnPos, previewComponent!, counter: _activePreviewCounter);
    }
  }

  void _initPreviewForComponent(ElectronicComponent comp, {Offset? spawnPos}) {
    switch (comp) {
      case Resistor(): _activePreviewCounter = _resCounter; break;
      case VoltageSource(): _activePreviewCounter = _vSourceCounter; break;
      case CurrentSource(): _activePreviewCounter = _cSourceCounter; break;
      case NetLabel(): _activePreviewCounter = _labelCounter; break;
      default: break;
    }
    if (_activePreviewCounter != null && comp.prefix.isNotEmpty) {
      comp.name = "${comp.prefix}${_activePreviewCounter!.value + 1}";
    }
    spawnPos ??= Offset.zero;
    _handlePlaceComponent(spawnPos, comp, counter: _activePreviewCounter);
  }

  void confirmPlacement() {
    if (previewComponent != null) {
      if (manager.addComponent(previewComponent!)) {
        if (_activePreviewCounter != null) _activePreviewCounter!.value++;
        final nextGhost = previewComponent!.clone(previewComponent!.position + Offset(40, 40));
        if (_activePreviewCounter != null && nextGhost.prefix.isNotEmpty) {
          nextGhost.name = '${nextGhost.prefix}${_activePreviewCounter!.value + 1}';
        }
        previewComponent = nextGhost;
        notifyListeners();
      }
    }
  }

  void cancelPlacement() {
    previewComponent = null;
    _activePreviewCounter = null;
    setMode(AppMode.select);
    notifyListeners();
  }

  void rotatePreview() {
    if (previewComponent != null) {
      // Qui potresti voler passare più informazioni, come il tipo di componente, per mostrare un dialogo personalizzato
      previewComponent!.rotation = (previewComponent!.rotation + 90) % 360;
      notifyListeners();
    }
  }

  // --- CONTEXT TOOLBAR ---

  void copySelected() {
    if (selectedComponent == null) return;
    
    final clone = selectedComponent!.clone(selectedComponent!.position + const Offset(40,40));
    selectedComponent!.isSelected = false;
    selectedComponent = null; 

    _initPreviewForComponent(clone, spawnPos: clone.position);
    notifyListeners();
  }

  void rotateSelected() {
    if (selectedComponent == null) return;
    manager.tryRotate(selectedComponent!);
    notifyListeners();
  }

  void deleteSelected() {
    if (selectedComponent == null) return;
    manager.components.remove(selectedComponent);
    selectedComponent = null;
    notifyListeners();
  }

  // --- LOGICA PRIVATA DEI SINGOLI STRUMENTI ---

  void _handlePlaceComponent(Offset pos, ElectronicComponent comp, {ValueNotifier<int>? counter}) {
    final snappedPos = manager.getSnappedPosition(pos);
    if (previewComponent == null) {
      _activePreviewCounter = counter; // Salviamo quale contatore è attivo per questa anteprima
      previewComponent = comp;
    }
    previewComponent!.position = snappedPos;
  }

  void _handleSelectDown(Offset pos) {
    _draggedLabelComponent = null;

    for (var c in manager.components.reversed) {
      if (c.labelsHitbox.contains(pos)) {
        _draggedLabelComponent = c;
        return;
      }
    }
    for (var c in manager.components.reversed) {
      if (c.contains(pos)) {
        draggedComponent = c;
        if (selectedComponent != null) selectedComponent!.isSelected = false;
        selectedComponent = c;
        c.isSelected = true;
        originalPos = c.position;
        return;
      }
    }
    // Se clicchiamo su uno spazio vuoto, deselezioniamo tutto
    if (selectedComponent != null) {
      selectedComponent!.isSelected = false;
      selectedComponent = null;
    }
  }

  void _handleSelectMove(Offset delta) {
    if (_draggedLabelComponent != null) {
      double rad = -_draggedLabelComponent!.rotation * math.pi / 180;
      double dx = delta.dx * math.cos(rad) - delta.dy * math.sin(rad);
      double dy = delta.dx * math.sin(rad) + delta.dy * math.cos(rad);
      _draggedLabelComponent!.labelsOffset += Offset(dx, dy);
      notifyListeners();
      return;
    }
    if (draggedComponent != null) {
      draggedComponent!.position += delta;
    }
  }

  void _handleSelectUp() {
    // 1. Se stavamo trascinando un'etichetta, resettiamo e usciamo
    if (_draggedLabelComponent != null) {
      _draggedLabelComponent = null;
      notifyListeners();
      return; 
    }
    // 2. Se non stavamo trascinando nemmeno un componente, usciamo
    if (draggedComponent == null) return;

    final duration = DateTime.now().difference(_downTime!);
    final dist = (originalPos! - draggedComponent!.position).distance;

    if (duration.inMilliseconds < 250 && dist < 5) {
      draggedComponent!.position = originalPos!;
    } else {
      manager.finalizeMove(draggedComponent!, originalPos!);
    }

    draggedComponent = null;
    originalPos = null;
    notifyListeners();
  }

  void _handleDrawWireDown(Offset pos) {
    tempWireStart = manager.getSnappedPosition(pos);
    tempWireCurrent = tempWireStart;
  }

  void _handleDrawWireMove(Offset pos) {
    if (tempWireStart == null) return;
    Offset rawCurrent = manager.getSnappedPosition(pos);
    double dx = rawCurrent.dx - tempWireStart!.dx;
    double dy = rawCurrent.dy - tempWireStart!.dy;

    if (dx.abs() > dy.abs() * 2) {dy = 0;}
    else if (dy.abs() > dx.abs() * 2) {dx = 0;}
    else {
      double minVal = math.min(dx.abs(), dy.abs());
      dx = minVal * dx.sign;
      dy = minVal * dy.sign;
    }
    tempWireCurrent = Offset(tempWireStart!.dx + dx, tempWireStart!.dy + dy);
  }

  void _handleDrawWireUp() {
    if (tempWireStart != null && tempWireCurrent != null) {
      manager.addWire(tempWireStart!, tempWireCurrent!);
      tempWireStart = null;
      tempWireCurrent = null;
    }
  }

  void _handleEraseDown(Offset pos) {eraseCurrent = pos;}

  void _handleEraseMove(Offset pos) {
    eraseCurrent = pos;
    manager.components.removeWhere((c) => c.contains(eraseCurrent!));
    manager.wires.removeWhere((w) => w.contains(eraseCurrent!));
  }

  void _handleEraseUp() {eraseCurrent = null;}

}