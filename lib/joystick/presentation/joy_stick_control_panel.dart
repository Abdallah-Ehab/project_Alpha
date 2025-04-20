import 'package:flutter/material.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/joystick/data/joy_stick_element.dart';


class JoyStickControlPanel extends StatefulWidget {
  final JoyStickElement joyStickElement;
  const JoyStickControlPanel({super.key, required this.joyStickElement});

  @override
  JoyStickControlPanelState createState() => JoyStickControlPanelState();
}

class JoyStickControlPanelState extends State<JoyStickControlPanel> {
  late TextEditingController entityNameController;
  late TextEditingController xNameController;
  late TextEditingController yNameController;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    entityNameController = TextEditingController(text: widget.joyStickElement.entityName);
    xNameController = TextEditingController(text: widget.joyStickElement.xName);
    yNameController = TextEditingController(text: widget.joyStickElement.yName);
  }

  @override
  void dispose() {
    entityNameController.dispose();
    xNameController.dispose();
    yNameController.dispose();
    super.dispose();
  }

  void _submit() {
    final entityName = entityNameController.text;
    final xName = xNameController.text;
    final yName = yNameController.text;

    Entity? entity = EntityManager().getActorByName(entityName);
    if (entity == null) {
      setState(() => errorMessage = "Entity '$entityName' not found.");
      return;
    }
    if (!entity.variables.containsKey(xName)) {
      setState(() => errorMessage = "Variable '$xName' not found.");
      return;
    }
    if (!entity.variables.containsKey(yName)) {
      setState(() => errorMessage = "Variable '$yName' not found.");
      return;
    }

    widget.joyStickElement.setEntityName(entityName);
    widget.joyStickElement.setXName(xName);
    widget.joyStickElement.setYName(yName);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Configure Joystick"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: entityNameController,
            decoration: const InputDecoration(labelText: 'Entity Name'),
          ),
          TextField(
            controller: xNameController,
            decoration: const InputDecoration(labelText: 'X Variable Name'),
          ),
          TextField(
            controller: yNameController,
            decoration: const InputDecoration(labelText: 'Y Variable Name'),
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}