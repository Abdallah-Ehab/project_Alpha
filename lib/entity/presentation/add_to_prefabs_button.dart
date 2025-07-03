import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_buttons.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';

class AddToPrefabsButton extends StatelessWidget {
  const AddToPrefabsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final entityManager = context.read<EntityManager>();
    final activeEntity = entityManager.activeEntity;

    return PixelArtButton(
      text: 'Add to Prefabs',
      callback: () {
        showDialog(
          context: context,
          builder: (context) => PrefabNameDialog(
            onSubmit: (prefabName) {
              entityManager.addPrefab(prefabName, activeEntity.copy());
            },
          ),
        );
      },
    );
  }
}

class PrefabNameDialog extends StatefulWidget {
  final void Function(String name) onSubmit;

  const PrefabNameDialog({super.key, required this.onSubmit});

  @override
  State<PrefabNameDialog> createState() => _PrefabNameDialogState();
}

class _PrefabNameDialogState extends State<PrefabNameDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prefab name cannot be empty')),
      );
      return;
    }

    widget.onSubmit(name);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Prefab Name'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'Prefab Name'),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
