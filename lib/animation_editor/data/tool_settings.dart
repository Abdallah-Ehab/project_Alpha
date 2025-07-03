import 'package:flutter/material.dart';

class ToolSettings extends ChangeNotifier {
  Color currentColor = Colors.black;
  double strokeWidth = 1.0;
  bool isEraser = false;

  void setColor(Color color) {
    currentColor = color;
    notifyListeners();
  }

  void setStrokeWidth(double width) {
    strokeWidth = width;
    notifyListeners();
  }

  void toggleEraser() {
    isEraser = !isEraser;
    notifyListeners();
  }

  void setEraser(bool value) {
    isEraser = value;
    notifyListeners();
  }
}
