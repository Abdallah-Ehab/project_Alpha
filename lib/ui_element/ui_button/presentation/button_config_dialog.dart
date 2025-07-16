import 'package:flutter/material.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_buttons.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_text_feild.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/ui_element/ui_button/data/abstract_button.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';



class ButtonConfigDialog extends StatefulWidget {
  final UIButtonElement buttonElement;

  const ButtonConfigDialog({super.key, required this.buttonElement});

  @override
  State<ButtonConfigDialog> createState() => _ButtonConfigDialogState();
}

class _ButtonConfigDialogState extends State<ButtonConfigDialog> {
  late TextEditingController entityController;
  late TextEditingController variableController;
  late TextEditingController labelController;
  late Color selectedColor;
  String? error;

  @override
  void initState() {
    super.initState();
    entityController = TextEditingController(text: widget.buttonElement.entityName);
    variableController = TextEditingController(text: widget.buttonElement.variableName);
    labelController = TextEditingController(text: widget.buttonElement.label ?? '');
    selectedColor = widget.buttonElement.color ?? Colors.blue;
  }

  @override
  void dispose() {
    entityController.dispose();
    variableController.dispose();
    labelController.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF222222),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white, width: 2),
        ),
        title: const Text(
          'Pick a Color',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 16,
            color: Colors.white
          ),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (Color color) {
              setState(() {
                selectedColor = color;
              });
            },
            enableAlpha: false,
            displayThumbColor: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          PixelArtButton(
            text: "Cancel",
            callback: () => Navigator.pop(context),
            fontsize: 14,
          ),
          PixelArtButton(
            text: "Select",
            callback: () => Navigator.pop(context),
            fontsize: 14,
          ),
        ],
      ),
    );
  }

  bool _variableExists(String variableName, Entity? entity) {
    if (widget.buttonElement.allowGlobals) {
      // Check global variables first (favor global over entity)
      if (EntityManager().globalVariables.containsKey(variableName)) {
        return true;
      }
    }
    
    // Then check entity variables
    if (entity != null && entity.variables.containsKey(variableName)) {
      return true;
    }
    
    return false;
  }

  void _submit() {
    final entityName = entityController.text.trim();
    final variableName = variableController.text.trim();
    final label = labelController.text.trim();

    if (label.isEmpty) {
      setState(() => error = "Label cannot be empty.");
      return;
    }

    final entity = EntityManager().getActorByName(entityName);
    if (entity == null) {
      setState(() => error = "Entity '$entityName' not found.");
      return;
    }
    if (!_variableExists(variableName, entity)) {
      setState(() => error = "Variable '$variableName' not found.");
      return;
    }

    widget.buttonElement.entityName = entityName;
    widget.buttonElement.variableName = variableName;
    widget.buttonElement.label = label;
    widget.buttonElement.color = selectedColor;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFF222222),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white, width: 2),
      ),
      title: const Text(
        "Configure Button",
        style: TextStyle(
          fontFamily: 'PressStart2P',
          fontSize: 18,
          color: Colors.white
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PixelatedTextField(
              keyboardType: TextInputType.text,
              borderColor: Colors.white,
              onChanged: (value) {},
              hintText: 'Entity Name',
              controller: entityController,
            ),
            SizedBox(height: 16),
            CheckboxListTile(
              title: const Text(
                'Allow Global Variables',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 12,
                  color: Colors.white
                ),
              ),
              value: widget.buttonElement.allowGlobals,
              onChanged: (bool? value) {
                setState(() {
                  widget.buttonElement.setAllowGlobals(value ?? false);
                  // Clear error message when checkbox state changes
                  error = null;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.white,
              checkColor: Color(0xFF222222),
            ),
            SizedBox(height: 16),
            PixelatedTextField(
              keyboardType: TextInputType.text,
              borderColor: Colors.white,
              onChanged: (value) {},
              hintText: 'Variable Name',
              controller: variableController,
            ),
            SizedBox(height: 16),
            PixelatedTextField(
              keyboardType: TextInputType.text,
              borderColor: Colors.white,
              onChanged: (value) {},
              hintText: 'Button Label',
              controller: labelController,
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _showColorPicker,
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: selectedColor,
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Tap to Select Color',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 12,
                      color: selectedColor.computeLuminance() > 0.5 
                          ? Colors.black 
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
      actions: [
        PixelArtButton(
          text: "Cancel",
          callback: () => Navigator.pop(context),
          fontsize: 14,
        ),
        PixelArtButton(
          text: "Submit",
          callback: _submit,
          fontsize: 14,
        ),
      ],
    );
  }
}