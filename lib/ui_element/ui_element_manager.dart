import 'package:flutter/cupertino.dart';
import 'package:scratch_clone/ui_element/joystick/data/joy_stick_element.dart';
import 'package:scratch_clone/ui_element/ui_element.dart';

class UiElementManager extends ChangeNotifier {
  Map<String,UIElement> uiElements = {
    "joyStick": JoyStickElement(),
  };
  UIElement? _activeUIElement;
  static final UiElementManager _instance = UiElementManager._internal();
  factory UiElementManager() => _instance;
  UiElementManager._internal() {
    _activeUIElement = null;
  }
  void addUiElement(String name,UIElement uiElement) {
    uiElements[name] = uiElement;
    notifyListeners();
  }
  void removeUiElement(String name) {
    uiElements.remove(name);
    notifyListeners();
  }

  UIElement? get activeUIElement => _activeUIElement;

  set activeUIElement(UIElement? value) {
    _activeUIElement = value;
    notifyListeners();
  }

}