import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_buttons.dart';
import 'package:scratch_clone/ui_element/alignment_picker.dart';
import 'package:scratch_clone/ui_element/joystick/data/joy_stick_element.dart';
import 'package:scratch_clone/ui_element/text_ui_element/text_ui_element.dart';
import 'package:scratch_clone/ui_element/ui_button/data/hold_button.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/four_button_config.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/three_button_config.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/two_button_config.dart';
import 'package:scratch_clone/ui_element/ui_element.dart';
import 'package:scratch_clone/ui_element/ui_element_manager.dart';



enum UIElementType {
  joystick,
  button,
  twoButtons,
  threeButtons,
  fourButtons,
  text,
}


class AddUIElementButton extends StatelessWidget {


  const AddUIElementButton({super.key});

  @override
  Widget build(BuildContext context) {
    final uiElementManager = context.watch<UiElementManager>();
    return PixelArtButton(
      
      text: "Add UI Element",
      callback: () {
        showDialog(
          context: context,
          builder: (context) => const _AddUIElementDialog(),
        ).then((element) {
          if (element != null && element is UIElement) {
            uiElementManager.addUiElement(element.type.name, element);
          
          }
        });
      }, fontsize: 16,
    );
  }
}

class _AddUIElementDialog extends StatefulWidget {
  const _AddUIElementDialog();

  @override
  State<_AddUIElementDialog> createState() => _AddUIElementDialogState();
}

class _AddUIElementDialogState extends State<_AddUIElementDialog> {
  String selectedType = 'joystick';
  Alignment selectedAlignment = Alignment.center;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add UI Element'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Type Selector
          DropdownButton<String>(
            value: selectedType,
            onChanged: (value) {
              setState(() {
                selectedType = value!;
              });
            },
      items: UIElementType.values.map((type) {
              return DropdownMenuItem(
                value: type.name,
                child: Text(type.name),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          const Text("Choose Alignment:"),
          const SizedBox(height: 4),

          // Alignment Picker UI
          AlignmentPicker(
            selected: selectedAlignment,
            onSelected: (alignment) {
              setState(() {
                selectedAlignment = alignment;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Cancel
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            UIElement element;
            switch (selectedType) {
              case 'joystick':
                element = JoyStickElement(alignment: selectedAlignment);
                break;
              case 'button':
                element = HoldButton(
                  alignment: selectedAlignment,
                );
              case 'twoButtons':
                element = TwoButtonConfiguration(
                  alignment: selectedAlignment,
                );
              case 'threeButtons':
                element = ThreeButtonConfiguration(
                  alignment: selectedAlignment,
                );
              case 'fourButtons':
                element = FourButtonConfiguration(
                  alignment: selectedAlignment,
                );
              case 'text':
              element = TextElement(
                alignment: selectedAlignment,
              );
              default:
                element = JoyStickElement(alignment: selectedAlignment);
                break;

            }
            Navigator.pop(context, element);
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}


