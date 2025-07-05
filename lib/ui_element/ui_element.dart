// ignore_for_file: public_member_api_docs, sort_constructors_first


import 'package:flutter/cupertino.dart';
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
}