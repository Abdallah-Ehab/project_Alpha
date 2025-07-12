import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
  Color selectedColor = Colors.white;
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
    selectedColor = widget.textElement.color ?? Colors.white;
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
    widget.textElement.color = selectedColor;

    Navigator.pop(context);
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF333333),
          title: const Text("Pick Text Color", style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) => setState(() => selectedColor = color),
              enableAlpha: false,
              labelTypes: const [ColorLabelType.rgb],
              pickerAreaHeightPercent: 0.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
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
        style: TextStyle(fontFamily: 'PressStart2P', fontSize: 18, color: Colors.white),
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
              const Text('Font:', style: TextStyle(color: Colors.white)),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: selectedFont,
                dropdownColor: const Color(0xFF333333),
                style: const TextStyle(color: Colors.white),
                iconEnabledColor: Colors.white,
                onChanged: (value) => setState(() => selectedFont = value!),
                items: availableFonts.map((font) {
                  return DropdownMenuItem(
                    value: font,
                    child: Text(font, style: TextStyle(fontFamily: font)),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text("Color:", style: TextStyle(color: Colors.white)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _pickColor,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
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
