import 'package:flutter/material.dart';

class AnimationControllerProvider with ChangeNotifier {
  late AnimationController _controller;

  bool _isPlaying = false;

  AnimationControllerProvider(TickerProvider vsync) {
    _controller = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 2),
    )..repeat(); 

    _controller.addListener(() {
      notifyListeners();
    });
  }

  double get progress => _controller.value;

  AnimationController get controller => _controller;

  void disposeController() {
    _controller.dispose();
  }
  void setDuration(int seconds){
    _controller.duration = Duration(seconds: seconds);
    notifyListeners();
  }
  set isPlaying(bool isPlaying){
    _isPlaying = isPlaying;
    notifyListeners();
  }
  bool get isPlaying => _isPlaying;
}