import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/camera_feature/data/camera_entity.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_buttons.dart';
import 'package:scratch_clone/entity/data/actor_entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';

class CreateEntityButton extends StatelessWidget {
  const CreateEntityButton({super.key});

  @override
  Widget build(BuildContext context) {

    return PixelArtButton(
      text: 'Create a new entity',
      callback: () {
        showDialog(
          context: context,
          builder: (context) => const _CreateEntityDialog(),
        );
      },
    );
  }
}

class _CreateEntityDialog extends StatefulWidget {
  const _CreateEntityDialog();

  @override
  State<_CreateEntityDialog> createState() => _CreateEntityDialogState();
}

class _CreateEntityDialogState extends State<_CreateEntityDialog> {
  EntityType _selectedType = EntityType.actors;
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final entityManager = context.read<EntityManager>();
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for the entity')),
      );
      return;
    }

    // Create the entity object based on type
    final entity = switch (_selectedType) {
      EntityType.actors => ActorEntity(name: name, position: Offset.zero, rotation: 0), // Customize if needed
      EntityType.cameras => CameraEntity(name: name, position: Offset.zero, rotation: 0), // Example
      // TODO: Handle this case.
      EntityType.lights => throw UnimplementedError(),
      // TODO: Handle this case.
      EntityType.sounds => throw UnimplementedError(),
    };

    entityManager.addEntity(_selectedType, name, entity);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Entity'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<EntityType>(
            value: _selectedType,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedType = value);
              }
            },
            items: EntityType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.name),
              );
            }).toList(),
          ),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Entity Name'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
