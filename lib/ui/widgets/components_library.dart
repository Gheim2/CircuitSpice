import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:circuit_spice/config/app_mode.dart';
import 'package:circuit_spice/config/component_registry.dart';
import 'package:circuit_spice/ui/widgets/component_icon.dart';

class CatalogItem {
  final String label;
  final AppMode mode;
  final double scale;
  final Offset iconOffset;
  CatalogItem({required this.label, required this.mode, this.scale = 1.0, this.iconOffset = Offset.zero});
}

class ComponentsLibrary extends StatefulWidget {
  final Function(AppMode) onComponentSelected;
  final VoidCallback onClose;
  const ComponentsLibrary({
    super.key,
    required this.onComponentSelected,
    required this.onClose,
  });
  @override
  State<ComponentsLibrary> createState() => _ComponentsLibraryState();
}

class _ComponentsLibraryState extends State<ComponentsLibrary> {
  String _searchQuery = '';

  late List<CatalogItem> _allComponents;

  @override
  void initState() {
    super.initState();
    _allComponents = globalComponentRegistry.map((m) => CatalogItem(
      label: m.label,
      mode: m.mode,
      scale: m.iconScale,
      iconOffset: m.iconOffset,
    )).toList();
    _allComponents.sort((a, b) => a.label.compareTo(b.label));
  }

  @override
  Widget build(BuildContext context) {
    final filteredComponents = _allComponents.where((item) => item
        .label.toLowerCase()
        .contains(_searchQuery.toLowerCase())).toList();

    return Container(
      width: 320,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 20),
                      filled: true,
                      fillColor: Colors.grey[800],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: widget.onClose,
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: filteredComponents.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final item = filteredComponents[index];
                return _buildGridItem(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(CatalogItem item) {
    return InkWell(
      onTap: () {
        widget.onComponentSelected(item.mode);
        widget.onClose();
      },
      borderRadius: BorderRadius.circular(8),
      hoverColor: Colors.white10,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ComponentIcon(
              mode: item.mode,
              size: 40,
              color: Colors.cyanAccent,
              customScale: item.scale,
              iconOffset: item.iconOffset,
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );

  }
}

// ==========================================
// SEZIONE PREVIEW PER VSCODE
// ==========================================
@Preview()
Widget componentsLibraryPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(), // Imposta il tema scuro per testare i tuoi colori
    home: Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: ComponentsLibrary(
          // ignore: avoid_print
          onComponentSelected: (mode) => print("Selected: $mode"),
          // ignore: avoid_print
          onClose: () => print("Library closed"),
        ),
      ),
    ),
  );
}