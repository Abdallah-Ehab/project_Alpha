import 'package:flutter/cupertino.dart';

class OnionSkinSettings extends ChangeNotifier {
  bool enabled = false;
  int prevFrames = 1;
  int nextFrames = 1;

  void toggle() {
    enabled = !enabled;
    notifyListeners();
  }

  void setPrev(int value) {
    prevFrames = value;
    notifyListeners();
  }

  void setNext(int value) {
    nextFrames = value;
    notifyListeners();
  }
}
