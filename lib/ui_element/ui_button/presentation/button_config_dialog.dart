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

    final entity = EntityManager().getActorByName(entityName);
    if (entity == null) {
      setState(() => error = "Entity '$entityName' not found.");
      return;
    }
    if (!entity.variables.containsKey(variableName)) {
      setState(() => error = "Variable '$variableName' not found in entity.");
      return;
    }

  

    widget.buttonElement.entityName = entityName;
    widget.buttonElement.variableName = variableName;
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
