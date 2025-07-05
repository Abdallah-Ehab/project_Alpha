import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_buttons.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_text_feild.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';

class AddToPrefabsButton extends StatelessWidget {
  const AddToPrefabsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final entityManager = context.read<EntityManager>();
    final activeEntity = entityManager.activeEntity;

    return PixelArtButton(
      fontsize: 12,
      text: 'Add to Prefabs',
      callback: () {

        if (activeEntity == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No active entity selected',style: TextStyle(
              fontFamily: 'PressStart2P', fontSize: 8, color: Colors.white)),
          ));
          return;
        }


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
      backgroundColor: const Color(0xFF222222),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.white, width: 2),
      ),
      title: const Text(
        'Enter Prefab Name',
        style: TextStyle(
          fontFamily: 'PressStart2P',
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PixelatedTextField(
            keyboardType: TextInputType.text,
            borderColor: Colors.white,
            controller: _controller,
            hintText: 'Prefab Name',
            onChanged: (_) {},
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
          callback: _submit,
          text: 'Save',
        ),
      ],
    );
  }
}