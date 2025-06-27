import 'package:flutter/material.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/button_type_selector.dart';

class AddUIButton extends StatelessWidget {
  const AddUIButton({super.key});

  void _showButtonTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ButtonTypeSelectorDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add),
      label: const Text("Add UI Button"),
      onPressed: () => _showButtonTypeDialog(context),
    );
  }
}
