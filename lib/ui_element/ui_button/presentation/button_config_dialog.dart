import 'package:flutter/material.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/ui_element/ui_button/data/abstract_button.dart';

class ButtonConfigDialog extends StatefulWidget {
  final UIButtonElement buttonElement;

  const ButtonConfigDialog({super.key, required this.buttonElement});

  @override
  State<ButtonConfigDialog> createState() => _ButtonConfigDialogState();
}

class _ButtonConfigDialogState extends State<ButtonConfigDialog> {
  late TextEditingController entityController;
  late TextEditingController variableController;
  late TextEditingController valueController;

  String? error;

  @override
  void initState() {
    super.initState();
    entityController = TextEditingController(text: widget.buttonElement.entityName);
    variableController = TextEditingController(text: widget.buttonElement.variableName);
    valueController = TextEditingController(
      text: widget.buttonElement.valueToSet?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    entityController.dispose();
    variableController.dispose();
    valueController.dispose();
    super.dispose();
  }

  void _submit() {
    final entityName = entityController.text.trim();
    final variableName = variableController.text.trim();
    final value = valueController.text.trim();

    final entity = EntityManager().getActorByName(entityName);
    if (entity == null) {
      setState(() => error = "Entity '$entityName' not found.");
      return;
    }
    if (!entity.variables.containsKey(variableName)) {
      setState(() => error = "Variable '$variableName' not found in entity.");
      return;
    }

    // Try parsing the value based on existing variable type
    final currentVar = entity.variables[variableName];
    dynamic parsedValue = value;

    if (currentVar is int) {
      parsedValue = int.tryParse(value);
    } else if (currentVar is double) {
      parsedValue = double.tryParse(value);
    } else if (currentVar is bool) {
      parsedValue = (value.toLowerCase() == 'true');
    }

    widget.buttonElement.entityName = entityName;
    widget.buttonElement.variableName = variableName;
    widget.buttonElement.valueToSet = parsedValue;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Configure Button"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: entityController,
            decoration: const InputDecoration(labelText: 'Entity Name'),
          ),
          TextField(
            controller: variableController,
            decoration: const InputDecoration(labelText: 'Variable Name'),
          ),
          TextField(
            controller: valueController,
            decoration: const InputDecoration(labelText: 'Value to Set'),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(error!, style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text("Submit"),
        ),
      ],
    );
  }
}
