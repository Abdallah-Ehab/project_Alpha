import 'package:flutter/material.dart';
import 'package:scratch_clone/ui_element/ui_button/data/hold_button.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/add_ui_element_button.dart';
import 'package:scratch_clone/ui_element/ui_element.dart';

class ThreeButtonConfiguration extends UIElement {
  ThreeButtonConfiguration({super.alignment= Alignment.bottomRight})
      : super(
          
          type: UIElementType.threeButtons,
        );

  @override
  Widget buildUIElementController() {
    // TODO: implement buildUIElementController
    throw UnimplementedError();
  }

  @override
  Widget buildWidget() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HoldButton().buildWidget(), // Top button
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HoldButton().buildWidget(), // Left
              const SizedBox(width: 40),
              HoldButton().buildWidget(), // Right
            ],
          ),
        ],
      ),
    );
  }
}
