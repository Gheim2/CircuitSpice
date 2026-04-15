import 'package:flutter/material.dart';
import '../models/electronic_component.dart';
import 'component_edit_form.dart';

// Una funzione globale per mostrare il menu
void showComponentEditor({
  required BuildContext context,
  required ElectronicComponent component,
  required VoidCallback onDelete,       // Cosa fare se preme Elimina
  required bool Function() onRotate,    // Cosa fare se preme Ruota (restituisce true se ha successo)
  required VoidCallback onUpdate,       // Cosa fare per aggiornare lo schermo
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Proprietà: ${component.name}'),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      
      // Il contenuto interno è generato dal componente stesso (Polimorfismo)
      content: ComponentEditForm(
        component: component, 
        onUpdate: onUpdate,
      ),
      
      actions: [
        TextButton(
          onPressed: () {
            onDelete();
            Navigator.pop(context); // Chiude il popup
          },
          style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
          child: const Text('Elimina'),
        ),
        TextButton(
          onPressed: () {
            bool success = onRotate();
            if (!success) {
              // Mostra un avviso se non c'è spazio
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Spazio insufficiente per ruotare!'))
              );
            }
            onUpdate(); // Forza il ridisegno per mostrare la rotazione
          },
          child: const Text('Ruota 90°'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            onUpdate();
            Navigator.pop(context);
            },
          icon: const Icon(Icons.check),
          label: const Text('Done'),
        ),
      ],
    ),
  );
}