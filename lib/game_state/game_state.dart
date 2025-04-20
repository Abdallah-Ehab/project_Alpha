import 'package:flutter/cupertino.dart';

class GameState extends ChangeNotifier{
  bool _isPlaying = false;

  set isPlaying(bool isPlaying){
    _isPlaying = isPlaying;
    notifyListeners();
  }

  bool get isPlaying => _isPlaying;
}