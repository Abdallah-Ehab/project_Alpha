import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_buttons.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/data/node_component.dart';
import 'package:scratch_clone/physics_feature/data/collider_component.dart';
import 'package:scratch_clone/sound_feature/data/sound_controller_component.dart';

class AddComponentButton extends StatelessWidget {
  const AddComponentButton({super.key});

  @override
  Widget build(BuildContext context) {
    final entityManager = context.read<EntityManager>();

    return PixelArtButton(
      fontsize: 12,
      text: 'Add Component',
      callback: () async {
        final componentType = await showDialog<String>(
          context: context,
          builder: (context) => const ComponentSelectionDialog(),
        );

        if (componentType == null) return;

        final entity = entityManager.activeEntity;

        // Create and add the selected component
        switch (componentType) {
          case 'AnimationController':
            entity?.addComponent(AnimationControllerComponent());
            break;
          case 'Collider':
            entity?.addComponent(ColliderComponent());
            break;
          case 'NodeComponent':
            entity?.addComponent(NodeComponent());
            break;
          case 'soundComponent':
            entity?.addComponent(SoundControllerComponent());
          default:
            debugPrint('Unknown component type: $componentType');
        }
      },
    );
  }
}


class ComponentSelectionDialog extends StatefulWidget {
  const ComponentSelectionDialog({super.key});

  @override
  State<ComponentSelectionDialog> createState() =>
      _ComponentSelectionDialogState();
}

class _ComponentSelectionDialogState extends State<ComponentSelectionDialog> {
  String? selectedType;

  final List<String> componentTypes = [
    'AnimationController',
    'Collider',
    'NodeComponent',
    'soundComponent'
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF222222),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.white, width: 2),
      ),
      title: const Text(
        'Select Component Type',
        style: TextStyle(
          fontFamily: 'PressStart2P',
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(

            borderRadius: BorderRadius.circular(16),
            value: selectedType,
            isExpanded: true,
            dropdownColor: const Color(0xFF333333),
            hint: const Text(
              'Select a component',
               style: TextStyle(
          fontFamily: 'PressStart2P',
          fontSize: 12,
          color: Colors.white,
        ),
            ),
            items: componentTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(
                  type,
                  style: TextStyle(
          fontFamily: 'PressStart2P',
          fontSize: 12,
          color: Colors.white,
        ),
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => selectedType = value),
          ),
        ],
      ),
      actions: [
        PixelArtButton(
          fontsize: 12,
          callback: () => Navigator.of(context).pop(),
          text: 'Cancel',
        ),
        const SizedBox(width: 16),
        PixelArtButton(
  fontsize: 12,
  callback: () {
    if (selectedType != null) {
      Navigator.of(context).pop(selectedType);
    }
  },
  text: 'Add',
),
      ],
    );
  }
}