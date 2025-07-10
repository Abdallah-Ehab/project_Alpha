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
  int _selectedLayer = 1; // Default layer number (1-based)

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
          ),
        ),
      );
      return;
    }

    final entity = switch (_selectedType) {
      EntityType.actors => ActorEntity(
          tag: 'player',
          name: name,
          position: Offset.zero,
          rotation: 0,
          layerNumber: _selectedLayer,
        ),
      EntityType.cameras => CameraEntity(
          name: name,
          position: Offset.zero,
          rotation: 0,
          layerNumber: _selectedLayer,
        ),
      EntityType.lights => LightEntity(
          name: name,
          position: Offset.zero,
          rotation: 0,
          color: Colors.red,
          layerNumber: _selectedLayer,
        ),
    };

    entityManager.addEntity(_selectedType, name, entity);
    Navigator.of(context).pop();
  }

  Widget _buildLayerSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Layer',
          style: TextStyle(
              fontFamily: 'PressStart2P', fontSize: 10, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(10, (index) {
            final layerNumber = index + 1;
            final isSelected = _selectedLayer == layerNumber;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedLayer = layerNumber;
              }),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blueAccent : Colors.grey[800],
                  border: Border.all(color: Colors.white),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$layerNumber',
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.white, width: 2),
      ),
      backgroundColor: const Color(0xFF222222),
      title: const Text(
        'Create New Entity',
        style: TextStyle(
            fontFamily: 'PressStart2P', fontSize: 18, color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left, color: Colors.white),
                  onPressed: () {
                    final currentIndex = EntityType.values.indexOf(_selectedType);
                    final newIndex = (currentIndex - 1 + EntityType.values.length) %
                        EntityType.values.length;
                    setState(() => _selectedType = EntityType.values[newIndex]);
                  },
                ),
                Text(
                  _selectedType.name,
                  style: const TextStyle(
                      fontFamily: 'PressStart2P', fontSize: 18, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right, color: Colors.white),
                  onPressed: () {
                    final currentIndex = EntityType.values.indexOf(_selectedType);
                    final newIndex = (currentIndex + 1) % EntityType.values.length;
                    setState(() => _selectedType = EntityType.values[newIndex]);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            PixelatedTextField(
              maxLength: 10,
              borderColor: Colors.white,
              keyboardType: TextInputType.text,
              onChanged: (value) {},
              hintText: 'Entity Name',
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            _buildLayerSelector(), // 🔵 Add this
          ],
        ),
      ),
      actions: [
        PixelArtButton(
          fontsize: 12,
          callback: () {
            Navigator.of(context).pop();
          },
          text: 'Cancel',
        ),
        const SizedBox(height: 16),
        PixelArtButton(
          fontsize: 12,
          callback: _submit,
          text: 'Create',
        ),
      ],
    );
  }
}
