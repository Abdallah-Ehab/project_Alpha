import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/camera_feature/data/camera_entity.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_buttons.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_text_feild.dart';
import 'package:scratch_clone/entity/data/actor_entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/entity/data/light_entity.dart';

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
      }, fontsize: 12,
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
        const SnackBar(
            content: Text(
          'Please enter a name for the entity',
          style: TextStyle(
              fontFamily: 'PressStart2P', fontSize: 8, color: Colors.white),
        )),
      );
      return;
    }

    // Create the entity object based on type
    final entity = switch (_selectedType) {
      EntityType.actors => ActorEntity(
          name: name,
          position: Offset.zero,
          rotation: 0), // Customize if needed
      EntityType.cameras =>
        CameraEntity(name: name, position: Offset.zero, rotation: 0), // Example
      
      EntityType.lights => LightEntity(
          name: name,
          position: Offset.zero,
          rotation: 0,
          color: Colors.red, // Default color, customize if needed
        ),
      // TODO: Handle this case.
      EntityType.sounds => throw UnimplementedError(),
    };

    entityManager.addEntity(_selectedType, name, entity);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.white, width: 2),
      ),
      backgroundColor: Color(0xFF222222),
      title: const Text(
        'Create New Entity',
        style: TextStyle(
            fontFamily: 'PressStart2P', fontSize: 18, color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_left,
                  color: Colors.white,
                ),
                onPressed: () {
                  final currentIndex = EntityType.values.indexOf(_selectedType);
                  final newIndex =
                      (currentIndex - 1 + EntityType.values.length) %
                          EntityType.values.length;
                  setState(() => _selectedType = EntityType.values[newIndex]);
                },
              ),
              Text(
                _selectedType.name,
                style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 18,
                    color: Colors.white), // Adjust style as needed
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_right,
                  color: Colors.white,
                ),
                onPressed: () {
                  final currentIndex = EntityType.values.indexOf(_selectedType);
                  final newIndex =
                      (currentIndex + 1) % EntityType.values.length;
                  setState(() => _selectedType = EntityType.values[newIndex]);
                },
              ),
            ],
          ),
          SizedBox(height: 16,),
          PixelatedTextField(
            borderColor: Colors.white,
            keyboardType: TextInputType.text,
            onChanged: (value) {},
            hintText: 'Entity Name',
            controller: _nameController,
          ),
          SizedBox(height: 16,),
          Row(children: [],)
        ],
      ),
      actions: [
        PixelArtButton(
          fontsize: 12,
          callback: () {
            Navigator.of(context).pop();
          },
          text: 'Cancel',
        ),
        SizedBox(
          height: 16,
        ),
        PixelArtButton(
          fontsize: 12,
          callback: _submit,
          text: 'Create',
        ),
      ],
    );
  }
}
