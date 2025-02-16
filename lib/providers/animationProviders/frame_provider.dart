import 'package:flutter/material.dart';

class FramesProvider extends ChangeNotifier{
  int _activeFrameIndex = 0;
  

  
  set activeFrameIndex(int newIndex){
    _activeFrameIndex = newIndex;
    notifyListeners();
  }

  int get activeFrameIndex => _activeFrameIndex;
  

  
}