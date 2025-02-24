import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:scratch_clone/core/functions.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';

class TickerStateProvider extends ChangeNotifier {
  late Ticker _ticker;
  final TickerProvider vsync;
  bool _isRunning = false;
  GameObjectManagerProvider gameObjectManagerProvider;

  TickerStateProvider({required this.vsync, required this.gameObjectManagerProvider}) {
    _ticker = vsync.createTicker(_gameLoopUpdate);
  }

  void _gameLoopUpdate(Duration elapsed) {
    var gameObjectManager = gameObjectManagerProvider;
    for (var gameObject in gameObjectManager.gameObjects.values) {
      execute(gameObject);
    }
  }

  bool get isRunning => _isRunning;

  void start() {
    
      _ticker.start();
      _isRunning = true;
      notifyListeners();
    
  }

  void stop() {
    
      _ticker.stop();
      _isRunning = false;
      notifyListeners();
    
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
