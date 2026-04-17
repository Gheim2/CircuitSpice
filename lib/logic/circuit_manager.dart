import 'package:circuit_spice/logic/circuit_engine.dart';
import 'package:circuit_spice/models/net_label.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/electronic_component.dart';
import '../models/wire.dart';
import '../models/ground.dart';
import 'dart:math' as math;

class CircuitManager {
  final List<ElectronicComponent> components = [];
  final List<Wire> wires = [];
  CircuitEngine? engine;
  static const double gridSize = 40.0;

  // ============================================================================
  // 1. GESTIONE COMPONENTI E FILI
  // ============================================================================
  bool addComponent(ElectronicComponent comp) {
    _applySnap(comp);
    if (!canPlaceComponent(comp)) {
      if (kDebugMode) {
        print("Piazzamento non valido: sovrapposizione fisica!");
      }
      return false;
    }
    components.add(comp);
    return true;
  }

  void addWire(Offset start, Offset end) {
    if (start != end) {
      wires.add(Wire(start, end));
      _optimizeWires(); // Unifica le sovrapposizioni ogni volta che aggiungi un filo!
    }
  }

  void eraseIntersecting(Offset p1, Offset p2) {
    components.removeWhere((comp) => _lineIntersectsRect(p1, p2, comp.collisionBox));
    wires.removeWhere((wire) => _segmentsIntersect(p1, p2, wire.start, wire.end));
  }

  void finalizeMove(ElectronicComponent comp, Offset originalPos) {
    _applySnap(comp);
    if (!canPlaceComponent(comp)) {
      comp.position = originalPos; // Rimbalza indietro
    }
  }
  
  bool tryRotate(ElectronicComponent comp) {
    int oldRot = comp.rotation;
    comp.rotation = (comp.rotation + 90) % 360;
    if (!canPlaceComponent(comp)) {
      comp.rotation = oldRot;
      return false;
    }
    return true;
  }
  
  // ============================================================================
  // 2. LOGICA DI POSIZIONAMENTO (SNAP E COLLISIONI)
  // ============================================================================
  void _applySnap(ElectronicComponent comp) {
    comp.position = Offset(
      (comp.position.dx / gridSize).round() * gridSize,
      (comp.position.dy / gridSize).round() * gridSize,
    );
  }

  Offset getSnappedPosition(Offset rawPos) {
    // Se siamo a meno di 25 pixel di distanza, il cursore viene "calamitato"
    for (var comp in components) {
      for (var nodePos in comp.globalNodePositions) {
        if ((nodePos - rawPos).distance < 25.0) {
          return nodePos; 
        }
      }
    }
    // Altrimenti, ci snappiamo normalmente all'incrocio della griglia
    return Offset(
      (rawPos.dx / gridSize).round() * gridSize,
      (rawPos.dy / gridSize).round() * gridSize,
    );
  }

  bool canPlaceComponent(ElectronicComponent newComp) {
    List<Offset> allForbidden = [];
    List<Offset> allExistingPins = [];
    
    for (var comp in components) {
      if (comp == newComp) continue; // Ignora se stesso durante lo spostamento
      allForbidden.addAll(comp.globalForbiddenPoints);
      allExistingPins.addAll(comp.globalNodePositions);
    }

    // REGOLA A: I PIN del nuovo componente non possono cadere nel corpo (punti proibiti) di un altro.
    for (var node in newComp.globalNodePositions) {
      if (_isPointOccupied(node, allForbidden)) return false;
    }
    // REGOLA B: Il CORPO (punti proibiti) del nuovo componente non può cadere sopra pin esistenti
    // o sopra corpi di altri componenti.
    for (var forbidden in newComp.globalForbiddenPoints) {
      if (_isPointOccupied(forbidden, allForbidden)) return false;
      if (_isPointOccupied(forbidden, allExistingPins)) return false;
    }

    return true;
  }

  void generateNetList() {
    _resetNets();
    _runFloodFill();
    _mergeNetLabels();
    int finalNetCount = _compactNetIds();
    if(kDebugMode) {
      print("Netlist generata! Trovate $finalNetCount Reti Elettriche uniche.");
    }
    engine = CircuitEngine(components, finalNetCount);
    engine!.solve();
  }

  void _resetNets() {
    for(var w in wires) {w.netId = -1;}
    for(var c in components) {c.pinNets.clear();}
  }

  // Algoritmo di Flood Fill per individuare i collegamenti fisici
  int _runFloodFill() {
    int currentNetId = 1;
    List<dynamic> unvisited = [];
    unvisited.addAll(wires);

    for (var comp in components) {
      var positions = comp.globalNodePositions;
      for (int i = 0; i < positions.length; i++) {
        unvisited.add({'comp': comp, 'index': i, 'pos': positions[i]});
      }
    }

    while (unvisited.isNotEmpty) {
      var startNode = unvisited.removeLast();
      List<dynamic> stack = [startNode];
      List<dynamic> currentNetElements = [];
      bool hasGround = false;

      while (stack.isNotEmpty) {
        var current = stack.removeAt(0);
        currentNetElements.add(current);
        if (current is Map && current['comp'] is Ground) hasGround = true;

        List<dynamic> toRemove = [];
        for (var neighbour in unvisited) {
          if (_touch(current, neighbour)) {
            stack.add(neighbour);
            toRemove.add(neighbour);
          }
        }
        for (var r in toRemove) { unvisited.remove(r); }
      }

      int assignedId = hasGround ? 0 : currentNetId;
      for (var element in currentNetElements) {
        if (element is Wire) {
          element.netId = assignedId;
        } else if (element is Map) {
          ElectronicComponent comp = element['comp'];
          comp.pinNets[element['index']] = assignedId;
        }
      }
      if (!hasGround) currentNetId++;
    }
    return currentNetId - 1;
  }

  void _mergeNetLabels() {
    Map<String, Set<int>> labelGroups = {};
    // Raggruppa i netId associati a ogni nome di etichetta
    for (var comp in components.whereType<NetLabel>()) {
      int? netId = comp.pinNets[0];
      if (netId != null && netId != -1) {
        labelGroups.putIfAbsent(comp.name, () => {}).add(netId);
      }
    }
    for (var group in labelGroups.values) {
      if (group.length > 1) {
        int targetNetId = group.contains(0) ? 0 : group.reduce(math.min); // Se c'è un Ground, usiamo 0, altrimenti il più piccolo
        group.remove(targetNetId);

        for (var comp in components) {
          for(int i = 0; i < comp.pinNets.length; i++) {
            if (group.contains(comp.pinNets[i])) {
              comp.pinNets[i] = targetNetId;
            }
          }
        }
        for (var w in wires) {
          if (group.contains(w.netId)) {
            w.netId = targetNetId;
          }
        }
      }
    }
  }

  // Ricompatta gli ID (es: 1, 3, 4 -> 1, 2, 3) per la matrice MNA
  int _compactNetIds() {
    Set<int> activeNets = {};
    for (var comp in components) { activeNets.addAll(comp.pinNets.values); }
    for (var wire in wires) { activeNets.add(wire.netId); }
    
    activeNets.remove(-1); // Rimuovi reti non valide
    activeNets.remove(0);  // GND rimane sempre 0

    List<int> sortedNets = activeNets.toList()..sort();
    Map<int, int> remapping = {};
    
    for (int i = 0; i < sortedNets.length; i++) {
      remapping[sortedNets[i]] = i + 1; // Nuova numerazione sequenziale
    }

    // Applica il remap
    for (var comp in components) {
      for (int i = 0; i < comp.pinNets.length; i++) {
        int currentId = comp.pinNets[i]!;
        if (currentId > 0 && remapping.containsKey(currentId)) {
          comp.pinNets[i] = remapping[currentId]!;
        }
      }
    }
    for (var wire in wires) {
      if (wire.netId > 0 && remapping.containsKey(wire.netId)) {
        wire.netId = remapping[wire.netId]!;
      }
    }

    return sortedNets.length; // Restituisce il numero esatto di nodi per l'MNA
  }

  // ============================================================================
  // 4. FUNZIONI MATEMATICHE E GEOMETRICHE PRIVATE
  // ============================================================================

  // ALGORITMO DI MERGING DEI FILI
  void _optimizeWires() {
    bool changed = true;
    while (changed) {
      changed = false;
      for (int i = 0; i < wires.length; i++) {
        for (int j = i + 1; j < wires.length; j++) {
          Wire w1 = wires[i];
          Wire w2 = wires[j];

          if (_areCollinearAndOverlapping(w1, w2)) {
            // Mettiamo i 4 estremi in una lista
            List<Offset> pts = [w1.start, w1.end, w2.start, w2.end];
            
            // Ordiniamo geometricamente (da sinistra a destra, o dal basso in alto)
            pts.sort((a, b) {
              int cmpX = a.dx.compareTo(b.dx);
              if (cmpX != 0) return cmpX;
              return a.dy.compareTo(b.dy);
            });

            // Sostituiamo il primo filo con un nuovo filo che unisce l'estremo più lontano e il più vicino
            wires[i] = Wire(pts.first, pts.last);
            wires.removeAt(j); // Cancelliamo il secondo filo
            changed = true; // Riavvia il ciclo per controllare altre fusioni
            break; 
          }
        }
        if (changed) break;
      }
    }
  }

  // Matematica per calcolare se due segmenti giacciono sulla stessa retta e si toccano
  bool _areCollinearAndOverlapping(Wire w1, Wire w2) {
    // Se i prodotti vettoriali non sono zero, formano un angolo, non sono sulla stessa retta
    if (_crossProduct(w1.start, w1.end, w2.start).abs() > 1 ||
        _crossProduct(w1.start, w1.end, w2.end).abs() > 1) {
      return false;
    }

    // Sono sulla stessa retta. Verifichiamo se le coordinate si accavallano
    double minX1 = math.min(w1.start.dx, w1.end.dx);
    double maxX1 = math.max(w1.start.dx, w1.end.dx);
    double minX2 = math.min(w2.start.dx, w2.end.dx);
    double maxX2 = math.max(w2.start.dx, w2.end.dx);

    double minY1 = math.min(w1.start.dy, w1.end.dy);
    double maxY1 = math.max(w1.start.dy, w1.end.dy);
    double minY2 = math.min(w2.start.dy, w2.end.dy);
    double maxY2 = math.max(w2.start.dy, w2.end.dy);

    bool overlapX = math.max(minX1, minX2) <= math.min(maxX1, maxX2) + 1;
    bool overlapY = math.max(minY1, minY2) <= math.min(maxY1, maxY2) + 1;

    return overlapX && overlapY;
  }

  double _crossProduct(Offset a, Offset b, Offset c) {
    return (b.dx - a.dx) * (c.dy - a.dy) - (b.dy - a.dy) * (c.dx - a.dx);
  }

  // Verifica se un segmento attraversa un rettangolo
  bool _lineIntersectsRect(Offset p1, Offset p2, Rect rect) {
    // Se uno dei due punti è dentro il rettangolo, c'è intersezione
    if (rect.contains(p1) || rect.contains(p2)) return true;

    // Altrimenti controlliamo l'intersezione con i 4 bordi del rettangolo
    Offset topLeft = rect.topLeft;
    Offset topRight = rect.topRight;
    Offset bottomLeft = rect.bottomLeft;
    Offset bottomRight = rect.bottomRight;

    return _segmentsIntersect(p1, p2, topLeft, topRight) ||
          _segmentsIntersect(p1, p2, topRight, bottomRight) ||
          _segmentsIntersect(p1, p2, bottomRight, bottomLeft) ||
          _segmentsIntersect(p1, p2, bottomLeft, topLeft);
  }

  // Algoritmo classico di intersezione tra due segmenti (A-B e C-D)
  bool _segmentsIntersect(Offset a, Offset b, Offset c, Offset d) {
    double det = (b.dx - a.dx) * (d.dy - c.dy) - (b.dy - a.dy) * (d.dx - c.dx);
    if (det == 0) return false; // Paralleli

    double lambda = ((d.dy - c.dy) * (d.dx - a.dx) + (c.dx - d.dx) * (d.dy - a.dy)) / det;
    double gamma = ((a.dy - b.dy) * (d.dx - a.dx) + (b.dx - a.dx) * (d.dy - a.dy)) / det;

    return (0 < lambda && lambda < 1) && (0 < gamma && gamma < 1);
  }

  bool _isPointOccupied(Offset p, Iterable<Offset> points) {
    return points.any((existing) => (existing - p).distance < 1.0);
  }

  bool _touch(dynamic a, dynamic b) {
    if (a is Wire && b is Wire) {
      return _isPointOnWireExact(a.start, b) || _isPointOnWireExact(a.end, b) ||
             _isPointOnWireExact(b.start, a) || _isPointOnWireExact(b.end, a);
    } else if (a is Wire && b is Map) { return _isPointOnWireExact(b['pos'], a); } 
      else if (a is Map && b is Wire) { return _isPointOnWireExact(a['pos'], b); } 
      else if (a is Map && b is Map) {
      return ((a['pos'] as Offset) - (b['pos'] as Offset)).distance < 0.1;
    }
    return false;
  }

  bool _isPointOnWireExact(Offset p, Wire w) {
    if ((p - w.start).distance < 0.1 || (p - w.end).distance < 0.1) return true;
    double l2 = math.pow(w.start.dx - w.end.dx, 2) + math.pow(w.start.dy - w.end.dy, 2).toDouble();
    if (l2 == 0) return false;
    double t = ((p.dx - w.start.dx) * (w.end.dx - w.start.dx) + (p.dy - w.start.dy) * (w.end.dy - w.start.dy)) / l2;
    if (t < 0 || t > 1) return false;
    Offset proj = Offset(w.start.dx + t * (w.end.dx - w.start.dx), w.start.dy + t * (w.end.dy - w.start.dy));
    return (p - proj).distance < 0.1;
  }
}