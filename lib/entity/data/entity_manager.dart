import 'package:flutter/widgets.dart';
import 'package:scratch_clone/camera_feature/data/camera_entity.dart';
import 'package:scratch_clone/component/component.dart';
import 'package:scratch_clone/entity/data/actor_entity.dart';
import 'package:scratch_clone/entity/data/entity.dart';



enum EntityType { actors, cameras, lights, sounds }
enum CameraType { main, game }
extension EntityTypeExtension on EntityType {
  String get name => toString().split('.').last;
}



class EntityManager extends ChangeNotifier {
  late Map<EntityType, Map<String, Entity>> _entities;
  Entity? _activeEntity;
  CameraEntity? _activeCamera;
  static final EntityManager _instance = EntityManager._internal();
  factory EntityManager() => _instance;
  EntityManager._internal() {
    _entities = {
      EntityType.actors: {
        "goku": ActorEntity(
          name: "goku", position: const Offset(0, 0), rotation: 0),
        "vegeta": ActorEntity(
          name: "vegeta", position: const Offset(100, 100), rotation: 0),
        "ground": ActorEntity(
          name: "ground",
          position: const Offset(0, 200),
          rotation: 0,
          width: 1000,
          height: 50,
          layerNumber: 0,
        ),
      },
      EntityType.cameras: {
        "mainCamera": CameraEntity(
          name: "mainCamera",
          position: const Offset(0, 100),
          rotation: 0,
          zoom: 1.0,
          isEditorCamera: true,
        ),
      }
    };
    _activeEntity = _entities[EntityType.actors]!["goku"];
    _activeCamera = _entities[EntityType.cameras]!["mainCamera"] as CameraEntity;
  }

  Map<EntityType, Map<String, Entity>> get entities => _entities;

  Iterable<Entity> get allEntities sync* {
    for (var typeMap in _entities.values) {
      yield* typeMap.values;
    }
  }

  void addEntity(EntityType type, String name, Entity entity) {
    _entities[type] ??= {};
    _entities[type]![name] = entity;
    notifyListeners();
  }

  void update(Duration dt) {
    for (var type in _entities.values) {
      for (var entity in type.values) {
        entity.update(dt);
      }
    }
  }

  Entity get activeEntity => _activeEntity!;
  CameraEntity get activeCamera => _activeCamera!;

  set activeEntity(Entity entity) {
    for (var typeMap in _entities.values) {
      if (typeMap.containsKey(entity.name)) {
        _activeEntity = entity;
        break;
      }
    }
    notifyListeners();
  }

  List<Entity> getSortedEntityByLayerNumber(EntityType type) {
    return _entities[type]!.values.toList()
      ..sort((a, b) => a.layerNumber.compareTo(b.layerNumber));
  }

  void setActiveEntityByName(EntityType type, String name) {
    if (_entities[type]?.containsKey(name) == true) {
      _activeEntity = _entities[type]![name];
      notifyListeners();
    }
  }

  void addComponentToActiveEntity(Component component) {
    _activeEntity?.components[component.runtimeType] = component;
    notifyListeners();
  }

  void removeEntity(EntityType type, String name) {
    _entities[type]?.remove(name);
    notifyListeners();
  }

  Entity? getActorByName(String name){
    return _entities[EntityType.actors]?[name];
  }

  void switchCamera(String name) {
    final cam = _entities[EntityType.cameras]?[name];
    if (cam is CameraEntity) {
      _activeCamera = cam;
      notifyListeners();
    }
  }

  void reset(){
    for (var type in _entities.values) {
      for (var entity in type.values) {
        entity.reset();
      }
    }
    
  }

  void switchCameraFromEditorToGame() {
  final cameras = _entities[EntityType.cameras]?.values.cast<CameraEntity>();

  final cam = cameras?.firstWhere((cam) => !cam.isEditorCamera);

  if (cam != null) {
    _activeCamera = cam;
    notifyListeners();
  }
}

}

