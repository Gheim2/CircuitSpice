# ⚡ Circuit Spice Simulator

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
**Circuit Spice Simulator** è un'applicazione mobile/desktop sviluppata in Flutter per la progettazione e simulazione di circuiti elettronici in tempo reale. Offre un'area di lavoro interattiva e un motore di calcolo basato su analisi nodale.

## ✨ Caratteristiche Principali

* **Workspace Interattivo:** Tela infinita con supporto a Pan & Zoom, snap alla griglia e sistema di rendering ad alte prestazioni basato su `CustomPainter`.
* **Componenti Modulari:** Libreria di componenti espandibile (Resistori, Generatori di Tensione/Corrente, Ground, Net Labels).
* **Smart Wiring:** Sistema di cablaggio intelligente con unione automatica dei fili sovrapposti e routing ottimizzato.
* **Motore Logico Dedicato:** * Generazione dinamica della Netlist tramite algoritmo di *Flood Fill*.
  * Risoluzione del circuito (tensioni nodali e correnti) basato su MNA (Modified Nodal Analysis).
* **Architettura Scalabile:** Struttura *Feature-Driven* (Vertical Slicing) con rigorosa separazione tra logica pura e rendering grafico.

---

## 🏗️ Architettura del Progetto

Il progetto segue rigidi principi di *Separation of Concerns* (SoC), separando i dati logico-matematici dal rendering visivo (UI). 

La struttura principale (Vertical Slicing) è così divisa:

   lib/
   │   main.dart
   │
   ├───components/               # Moduli indipendenti per ogni componente elettronico
   │   │   components.dart
   │   │   core.dart
   │   │
   │   ├───base/                 # Interfacce astratte
   │   │       electronic_component.dart
   │   │       node.dart
   │   │       symbol_renderer.dart
   │   │
   │   ├───current_source/       # Logica (Model) + Grafica (UI) del Generatore
   │   │       current_source.dart
   │   │       current_source_ui.dart
   │   │
   │   ├───resistor/             # Logica (Model) + Grafica (UI) del Resistore
   │   │       resistor.dart
   │   │       resistor_ui.dart
   │   │
   │   └───...
   │
   ├───config/                   # File di Configurazione
   │       app_mode.dart
   │       component_registry.dart
   │
   ├───logic/                    # Core engine: CircuitManager, InteractionController, Math/MNA
   │
   └───ui/                       # Interfaccia utente: Viewers, Toolbars, Renderer Manager

---

Il simulatore è costruito per essere estremamente scalabile. L'aggiunta di nuovi componenti è governata da un **Registro Centrale** (`ComponentManifest`), eliminando la necessità di modificare decine di file.

Per aggiungere un nuovo componente elettrico, basta:
1. Creare i file per la logica (`Component`) e il disegno (`SymbolRenderer`).
2. Aggiungere una singola voce al `globalComponentRegistry`.
*Il sistema (Libreria UI, Factory di istanziazione, e Renderer Grafico) si aggiornerà e configurerà in automatico leggendo il manifesto!*

## 🚀 Come Iniziare

### Prerequisiti
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (versione 3.x o superiore)
* Dart SDK

### Installazione

1. Clona il repository:
   ```bash
   git clone https://github.com/tuo-username/circuit_spice.git

2. Entra nella directory del progetto:
   ```bash
   cd circuit_spice

3. Scarica le dipendenze:
   ```bash
   flutter pub get

4. Avvia l'applicazione:
   ```bash
   flutter run

---

## 🛠️ Stack Tecnologico & Librerie

* **Framework Principale:** Flutter / Dart
* **Matematica & Geometria:** `vector_math` (per matrici di trasformazione e calcoli spaziali complessi)
* **Rendering:** `Canvas` API nativa di Flutter con pattern Registry per componenti illimitati.

---

## 🗺️ Roadmap / Sviluppi Futuri

- [x] Motore di rendering base e pan/zoom
- [x] Piazzamento componenti e smart routing dei fili
- [x] Generazione Netlist (Flood Fill) e base MNA
- [ ] Integrazione componenti non lineari (Diodi, Transistor)
- [ ] Grafici nel dominio del tempo (Analisi Transitoria)
- [ ] Esportazione netlist in formato SPICE compatibile

---

## 🤝 Contribuire

I contributi sono benvenuti! Se vuoi aggiungere un nuovo componente:
1. Crea una nuova cartella sotto `lib/components/`
2. Implementa il Modello estendendo `ElectronicComponent` (solo logica/geometria).
3. Implementa il Renderer estendendo `SymbolRenderer` (solo grafica/path).
4. Registra il componente aggiungendo il suo manifesto nel `globalComponentRegistry` (`lib/config/component_registry.dart`).

---