// ignore_for_file: public_member_api_docs, sort_constructors_first


import 'package:flutter/cupertino.dart';
import 'package:scratch_clone/ui_element/joystick/data/joy_stick_element.dart';
import 'package:scratch_clone/ui_element/ui_button/data/hold_button.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/add_ui_element_button.dart';

abstract class UIElement {
  Alignment alignment;
  UIElementType type;
  UIElement({
    required this.alignment,
    required this.type,
  });
  Widget buildUIElementController();
  Widget buildWidget(); // Added to render the actual UI element

   Map<String, dynamic> toJson();

 factory UIElement.fromJson(Map<String, dynamic> json) {
    final String typeString = json['type'];
    final UIElementType type = UIElementType.values.firstWhere(
      (e) => e.toString() == typeString,
      orElse: () => throw Exception('Unknown UIElementType: $typeString'),
    );

    switch (type) {
      case UIElementType.button:
        return HoldButton.fromJson(json);
      case UIElementType.joystick:
        return JoyStickElement.fromJson(json);
      default:
        throw Exception('Unsupported UIElementType: $type');
    }
  }
}


Map<String, double> alignmentToJson(Alignment alignment) {
  return {'x': alignment.x, 'y': alignment.y};
}

Alignment alignmentFromJson(Map<String, dynamic> json) {
  return Alignment(
    (json['x'] ?? 0).toDouble(),
    (json['y'] ?? 0).toDouble(),
  );
}
