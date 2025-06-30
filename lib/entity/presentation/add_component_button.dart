import 'package:flutter/cupertino.dart';
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
            entity.addComponent(AnimationControllerComponent());
            break;
          case 'Collider':
            entity.addComponent(ColliderComponent());
            break;
          case 'NodeComponent':
            entity.addComponent(NodeComponent());
            break;
          case 'soundComponent':
            entity.addComponent(SoundControllerComponent());
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
    // Add more types here
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Component Type'),
      content: DropdownButton<String>(
        value: selectedType,
        isExpanded: true,
        hint: const Text('Select a component'),
        items: componentTypes
            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
            .toList(),
        onChanged: (value) => setState(() => selectedType = value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: selectedType != null
              ? () => Navigator.of(context).pop(selectedType)
              : null,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
