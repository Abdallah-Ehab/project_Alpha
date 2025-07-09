import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_buttons.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_text_feild.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/ui_element/text_ui_element/text_ui_element.dart';

class TextElementConfigDialog extends StatefulWidget {
  final TextElement textElement;

  const TextElementConfigDialog({super.key, required this.textElement});

  @override
  State<TextElementConfigDialog> createState() => _TextElementConfigDialogState();
}

class _TextElementConfigDialogState extends State<TextElementConfigDialog> {
  late TextEditingController entityController;
  late TextEditingController variableController;
  late String selectedFont;
  String? error;

  final List<String> availableFonts = [
    'PressStart2P',
    'Roboto',
    'Monospace',
    'Courier',
    'Arial',
  ];

  @override
  void initState() {
    super.initState();
    entityController = TextEditingController(text: widget.textElement.entityName ?? '');
    variableController = TextEditingController(text: widget.textElement.boundVariable);
    selectedFont = widget.textElement.fontFamily ?? 'PressStart2P';
  }

  @override
  void dispose() {
    entityController.dispose();
    variableController.dispose();
    super.dispose();
  }

  void _submit() {
    final entityName = entityController.text.trim();
    final variableName = variableController.text.trim();

    final entity = EntityManager().getActorByName(entityName);
    if (entity == null) {
      setState(() => error = "Entity '$entityName' not found.");
      return;
    }
    if (!entity.variables.containsKey(variableName)) {
      setState(() => error = "Variable '$variableName' not found in entity.");
      return;
    }

    widget.textElement.entityName = entityName;
    widget.textElement.boundVariable = variableName;
    widget.textElement.fontFamily = selectedFont;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF222222),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white, width: 2),
      ),
      title: const Text(
        "Configure Text UI",
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
            onChanged: (_) {},
            hintText: 'Entity Name',
            controller: entityController,
          ),
          const SizedBox(height: 16),
          PixelatedTextField(
            keyboardType: TextInputType.text,
            borderColor: Colors.white,
            onChanged: (_) {},
            hintText: 'Variable Name',
            controller: variableController,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Font:',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: selectedFont,
                dropdownColor: const Color(0xFF333333),
                style: const TextStyle(color: Colors.white),
                iconEnabledColor: Colors.white,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedFont = value);
                  }
                },
                items: availableFonts
                    .map((font) => DropdownMenuItem(
                          value: font,
                          child: Text(font, style: TextStyle(fontFamily: font)),
                        ))
                    .toList(),
              ),
            ],
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(error!, style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
      actions: [
        PixelArtButton(text: "Cancel", callback: () => Navigator.pop(context), fontsize: 14),
        PixelArtButton(text: "Submit", callback: _submit, fontsize: 14),
      ],
    );
  }
}
