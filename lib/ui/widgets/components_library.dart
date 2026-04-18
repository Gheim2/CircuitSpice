import 'package:flutter/material.dart';

class ComponentsLibrary extends StatelessWidget {

  const ComponentsLibrary({super.key});

  // A big container with all the components, scrollable, with a search bar on top

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey[900],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search components...',
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                // Qui andranno i componenti, per ora metto dei placeholder
                _buildComponentItem(context, "Resistor"),
                _buildComponentItem(context, "Capacitor"),
                _buildComponentItem(context, "Inductor"),
                _buildComponentItem(context, "Battery"),
                _buildComponentItem(context, "Diode"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentItem(BuildContext context, String name) {
    return ListTile(
      title: Text(
        name,
        style: TextStyle(color: Colors.white),
      ),
      onTap: () {
        // Handle component selection
      },
    );
  }
}