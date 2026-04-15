import 'package:flutter/material.dart';
import '../models/electronic_component.dart';
import '../logic/engineering_utils.dart';

class ComponentEditForm extends StatefulWidget {
  final ElectronicComponent component;
  final VoidCallback onUpdate;

  const ComponentEditForm({
    super.key,
    required this.component,
    required this.onUpdate,
  });

  @override
  State<ComponentEditForm> createState() => _ComponentEditFormState();
}

class _ComponentEditFormState extends State<ComponentEditForm> {
  late TextEditingController _nameController;
  late TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.component.name);
    _valueController = TextEditingController(
      text: EngineeringUtils.formatValue(widget.component.value).replaceAll(' ', ''));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (val) { widget.component.name = val; widget.onUpdate(); },
              ),
            ),
            const SizedBox(width: 8,),
            Column(
              children: [
                const Text('Show Name', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Checkbox(
                  value: widget.component.showName,
                  onChanged: (val) {
                    setState(() => widget.component.showName = val ?? true);
                    widget.onUpdate();
                  },
                ),
              ],
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children:[
            if (widget.component.isValueEditable) ...[
              Expanded(
                child: TextField(
                controller: _valueController,
                decoration: InputDecoration(labelText: 'Value', suffixText: widget.component.unit),
                onChanged: (val) { 
                  widget.component.value = EngineeringUtils.parseValue(val); 
                  widget.onUpdate(); 
                  },
                ),
              ),
            ],
            const SizedBox(width: 8,),
            Column(
              children: [
                const Text('Show Value', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Checkbox(
                  value: widget.component.showValue,
                  onChanged: (val) {
                    setState(() => widget.component.showValue = val ?? true);
                    widget.onUpdate();
                  },
                ),
              ],
            ),
          ]
        )
      ]
    );
  }
}
