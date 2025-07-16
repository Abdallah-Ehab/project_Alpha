import 'package:flutter/cupertino.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';

class GameErrorManager with ChangeNotifier {
  static final GameErrorManager _instance = GameErrorManager._internal();
  factory GameErrorManager() => _instance;
  GameErrorManager._internal();

  final List<GameError> _errors = [];
  
  List<GameError> get errors => List.unmodifiable(_errors);
  bool get hasErrors => _errors.isNotEmpty;

  void reportError(String message, {
    Entity? entity,
    NodeModel? node,
    String? componentType,
  }) {
    final error = GameError(
      message: message,
      timestamp: DateTime.now(),
      entity: entity,
      node: node,
      componentType: componentType,
    );
    
    _errors.add(error);
    notifyListeners();
  }

  void clearErrors() {
    _errors.clear();
    notifyListeners();
  }

  void removeError(GameError error) {
    _errors.remove(error);
    notifyListeners();
  }
}

class GameError {
  final String message;
  final DateTime timestamp;
  final Entity? entity;
  final NodeModel? node;
  final String? componentType;

  GameError({
    required this.message,
    required this.timestamp,
    this.entity,
    this.node,
    this.componentType,
  });
}