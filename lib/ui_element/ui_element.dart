// ignore_for_file: public_member_api_docs, sort_constructors_first


import 'package:flutter/cupertino.dart';

abstract class UIElement {
  Alignment alignment;
  UIElement({
    this.alignment = Alignment.centerLeft,
  });
  Widget buildUIElementController();
  Widget buildWidget(); // Added to render the actual UI element
}