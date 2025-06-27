import 'package:flutter/material.dart';
import 'package:scratch_clone/ui_element/ui_button/data/abstract_button.dart';
import 'package:scratch_clone/ui_element/ui_button/data/button_types.dart';
import 'package:scratch_clone/ui_element/ui_button/data/hold_button.dart';
import 'package:scratch_clone/ui_element/ui_button/data/long_press_button.dart';
import 'package:scratch_clone/ui_element/ui_button/data/tap_button.dart';
import 'package:scratch_clone/ui_element/ui_element_manager.dart';

class ButtonTypeSelectorDialog extends StatelessWidget {
  const ButtonTypeSelectorDialog({super.key});

  void _createAndAddButton(ButtonType type, BuildContext context) {
    final manager = UiElementManager();

    final String id = "${type.name}_${DateTime.now().millisecondsSinceEpoch}";
    UIButtonElement newButton;

    switch (type) {
      case ButtonType.tap:
        newButton = TapButton();
        break;
      case ButtonType.hold:
        newButton = HoldButton();
        break;
      case ButtonType.longPress:
        newButton = LongPressButton();
        break;
    }

    manager.addUiElement(id, newButton);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Button Type"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: ButtonType.values.map((type) {
          return ListTile(
            title: Text(type.label),
            onTap: () => _createAndAddButton(type, context),
          );
        }).toList(),
      ),
    );
  }
}
