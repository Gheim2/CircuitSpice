// import 'package:circuit_spice/models/component_label.dart';
import 'package:circuit_spice/config/app_mode.dart';
import 'package:circuit_spice/models/current_source.dart';
import 'package:circuit_spice/models/net_label.dart';
import 'package:flutter/material.dart';
import '../models/electronic_component.dart';
import '../models/resistor.dart';
import '../models/ground.dart';
import '../models/v_source.dart';
import 'circuit_manager.dart';
import 'dart:math' as math;

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

  // Variabili temporanee (Spostate dal Main a qui)
  ElectronicComponent? draggedComponent;
  ElectronicComponent? _draggedLabelComponent;
  ElectronicComponent? selectedComponent;
  ElectronicComponent? previewComponent;
  Offset? originalPos;
  Offset? eraseStart;
  Offset? eraseCurrent;
  Offset? tempWireStart;
  Offset? tempWireCurrent;

  InteractionController(this.manager);

  bool get isCanvasLocked =>
    draggedComponent != null ||
    _draggedLabelComponent != null ||
    tempWireStart != null ||
    eraseStart != null;

  // Metodo per cambiare modalità dalla Toolbar
  void setMode(AppMode mode) {
    currentMode = mode;
    selectedComponent?.isSelected = false; // Deseleziona il componente attualmente selezionato
    selectedComponent = null;
    previewComponent = null; // Resettiamo l'anteprima quando cambiamo strumento
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

    switch (currentMode) {
      case AppMode.select: _handleSelectDown(pos); break;
      case AppMode.placeResistor: _handlePlaceComponent(pos, Resistor(name: 'R${_resCounter.value + 1}', value: 1000), counter: _resCounter); break;
      case AppMode.drawWire: _handleDrawWireDown(pos); break;
      case AppMode.erase: _handleEraseDown(pos); break;
      case AppMode.placeGround: _handlePlaceComponent(pos, Ground()); break;
      case AppMode.placeVoltage: _handlePlaceComponent(pos, VoltageSource(name: 'V${_vSourceCounter.value + 1}', value: 5.0), counter: _vSourceCounter); break;
      case AppMode.placeCurrent: _handlePlaceComponent(pos, CurrentSource(name: 'I${_cSourceCounter.value + 1}', value: 1.0), counter: _cSourceCounter); break;
      case AppMode.placeLabelNet: _handlePlaceComponent(pos, NetLabel(), counter: _labelCounter); break;
      // default: break;
    }
    notifyListeners(); // Ridisegna per mostrare selezioni o anteprime
  }

  void onPointerMove(PointerMoveEvent event) {
    final pos = event.localPosition;
    switch (currentMode) {
      case AppMode.select: _handleSelectMove(event.localDelta); break;
      case AppMode.drawWire: _handleDrawWireMove(pos); break;
      case AppMode.erase: _handleEraseMove(pos); break;
      default: // Per gli strumenti di posizionamento, aggiorniamo la posizione dell'anteprima
        if (previewComponent != null) {
          previewComponent!.position = manager.getSnappedPosition(pos);
        }
        break;
    }
    notifyListeners();
  }

  void onPointerUp(PointerEvent event, Function(ElectronicComponent) onEdit) {
    switch (currentMode) {
      case AppMode.select: _handleSelectUp(); break;
      case AppMode.drawWire: _handleDrawWireUp(); break;
      case AppMode.erase: _handleEraseUp(); break;
      default: break;
    }
    notifyListeners();
  }

  // --- AZIONI DEL MENU DI ANTEPRIMA ---
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

  // --- AZIONI DELLA CONTEXT TOOLBAR ---
  void copySelected() {
    if (selectedComponent == null) return;
    final clone = selectedComponent!.clone(selectedComponent!.position + const Offset(40,40));
    if (manager.addComponent(clone)) {
      selectedComponent!.isSelected = false;
      selectedComponent = clone;
      clone.isSelected = true;
      notifyListeners();
    }
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

  void _handleEraseDown(Offset pos) {
    eraseStart = pos;
    eraseCurrent = pos;
  }

  void _handleEraseMove(Offset pos) {
    if (eraseStart != null) {
      eraseCurrent = pos;
    }
  }

  void _handleEraseUp() {
    if (eraseStart == null || eraseCurrent == null) return;
    final dist = (eraseStart! - eraseCurrent!).distance;
    final duration = DateTime.now().difference(_downTime!);
    if (duration.inMilliseconds < 250 && dist < 10) {
      manager.components.removeWhere((c) => c.contains(eraseStart!));
      manager.wires.removeWhere((w) => w.contains(eraseStart!));
    } else {
      manager.eraseIntersecting(eraseStart!, eraseCurrent!);
    }
    eraseStart = null;
    eraseCurrent = null;
  }

  
  // void _handlePlaceResistor(Offset pos) {
  //   _resCounter++;
  //   final res = Resistor(position: pos, name: 'R$_resCounter', value: 1000);
  //   if (!manager.addComponent(res)) _resCounter--;
  // }

  // void _handlePlaceGround(Offset pos) {
  //   final ground = Ground(position: pos);
  //   manager.addComponent(ground);
  // }

  // void _handlePlaceVoltage(Offset pos) {
  //   _vSourceCounter++;
  //   final vSource = VoltageSource(position: pos, value: 5, name: 'V$_vSourceCounter');
  //   if (!manager.addComponent(vSource)) _vSourceCounter--;
  // }

  // void _handlePlaceCurrent(Offset pos) {
  //   _cSourceCounter++;
  //   final cSource = CurrentSource(position: pos, value: 1.0, name: 'I$_cSourceCounter');
  //   if (!manager.addComponent(cSource)) _cSourceCounter--;
  // }

  // void _handlePlaceLabelNet(Offset pos) {
  //   _labelCounter++;
  //   final label = NetLabel(
  //     position: pos,
  //     name: 'NET$_labelCounter', // Genera nomi incrementali di default
  //   );
  //   if (!manager.addComponent(label)) _labelCounter--;
  // }


}