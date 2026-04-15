import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook/widgetbook.dart'; // Importante per usare i knobs
import '../../../ui/toolbar.dart'; // Assicurati che il percorso sia corretto
import '../../../config/app_mode.dart';

@widgetbook.UseCase(
  name: 'Standard Bottom Bar',
  type: WorkspaceToolbar,
)
Widget buildWorkspaceToolbarUseCase(BuildContext context) {
  return Scaffold(
    // Mettiamo uno sfondo grigio per simulare il canvas e far risaltare la toolbar scura
    backgroundColor: Colors.grey[900], 
    
    // Inseriamo la toolbar esattamente dove andrebbe nell'app reale
    bottomNavigationBar: WorkspaceToolbar(
      
      // LA MAGIA DEI KNOBS: Creiamo un menu a tendina in Widgetbook per cambiare modalità!
      currentMode: context.knobs.object.dropdown(label: "label", options: AppMode.values),
      
      // Essendo in isolamento, le funzioni stampano solo in console
      onModeChanged: (mode) {
        debugPrint('L\'utente ha cliccato il tasto per la modalità: $mode');
      },
      onPlayPressed: () {
        debugPrint('L\'utente ha cliccato Simulate!');
      },
      
    ),
  );
}