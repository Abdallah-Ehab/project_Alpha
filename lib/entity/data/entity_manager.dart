import 'package:flutter/widgets.dart';
import 'package:scratch_clone/component/component.dart';
import 'package:scratch_clone/entity/data/entity.dart';







class EntityManager extends ChangeNotifier {
  late Map<String, Entity> _entities;
  Entity? _activeEntity;
  EntityManager() {
    _entities = {
      "goku": Entity(
          name: "goku", position: const Offset(0, 100), rotation: 0, scale: 1),
      "vegeta": Entity(
          name: "vegeta",
          position: const Offset(100, 100),
          rotation: 0,
          scale: 1),
    };
    _activeEntity = _entities["goku"]!;
  }

  Map<String, Entity> get entities => _entities;

  void addEntity(String entityName, Entity entity) {
    _entities[entityName] = entity;
    notifyListeners();
  }
  
  void update(Duration dt) {
    for (var entity in _entities.values) {
      entity.update(dt,this);
    }
  }

  Entity get activeEntity => _activeEntity!;

  set activeEntity(Entity entity) {
    if (_entities.containsKey(entity.name)) {
      _activeEntity = entity;
    }
    notifyListeners();
  }

  void setActiveEntityByName(String name){
    if (_entities.containsKey(name)) {
      _activeEntity = _entities[name];
    }
    notifyListeners();
  }

  void addComponentToActiveEntity(Component component){
    _activeEntity!.components[component.runtimeType] = component;
    notifyListeners();
  }

  void removeEntity(String entityName) {
    _entities.remove(entityName);
    notifyListeners();
  }

}
