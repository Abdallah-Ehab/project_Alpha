import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/ui_element/ui_element_manager.dart';

class UIElementsLayer extends StatelessWidget {
  const UIElementsLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final uiManager = context.watch<UiElementManager>();
    return Stack(
      children: uiManager.uiElements.entries.map((entry) {
        final uiElement = entry.value;
        return Align(
          alignment: uiElement.alignment,
          child: uiElement.buildWidget(),
        );
      }).toList(),
    );
  }
}