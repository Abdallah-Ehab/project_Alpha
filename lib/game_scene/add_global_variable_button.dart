import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_buttons.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/utility/pan_end_functions.dart';

class AddVariableButton extends StatelessWidget {


  const AddVariableButton({super.key});

  @override
  Widget build(BuildContext context) {
    
    return PixelArtButton(
      text: 'Add Variable',
      fontsize: 12,
      callback: () => _showAddVariableDialog(context),
    );
  }

  void _showAddVariableDialog(BuildContext context) {
    final entityManager = context.watch<EntityManager>(); 
    final TextEditingController nameController = TextEditingController();
    final TextEditingController valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF333333),
          title: const Text(
            'Add Variable',
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(
                  labelText: 'Value',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                String name = nameController.text.trim();
                String rawValue = valueController.text.trim();
                dynamic value;
                
                value = parseStringValue(rawValue);

                if (name.isNotEmpty) {
                  entityManager.addGlobalVariable(name, value);
                }

                Navigator.of(context).pop();
              },
              child: const Text(
                'Add',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
