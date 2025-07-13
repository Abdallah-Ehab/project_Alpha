import 'package:flutter/material.dart';
import 'package:scratch_clone/ui_element/ui_button/data/hold_button.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/add_ui_element_button.dart';
import 'package:scratch_clone/ui_element/ui_element.dart';

class FourButtonConfiguration extends UIElement {
  FourButtonConfiguration({super.alignment = Alignment.centerRight})
      : super(

          type: UIElementType.fourButtons,
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
          // Top
          HoldButton().buildWidget(),
          const SizedBox(height: 8),
          // Left, Center Spacer, Right
          Row(
            
            mainAxisSize: MainAxisSize.min,
            children: [
              HoldButton().buildWidget(),
              const SizedBox(width: 40),
              HoldButton().buildWidget(),
            ],
          ),
          const SizedBox(height: 8),
          // Bottom
          HoldButton().buildWidget(),
        ],
      ),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
