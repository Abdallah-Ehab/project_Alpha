import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/camera_feature/data/camera_entity.dart';
import 'package:scratch_clone/component/component.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:flutter/material.dart';


enum EntityType { actors, cameras, lights, sounds }



extension EntityTypeExtension on EntityType {
  String get name => toString().split('.').last;
}

class EntityManager extends ChangeNotifier {
  late Map<EntityType, Map<String, Entity>> _entities;

  Entity? _activeEntity;
  CameraEntity? _activeCamera;
  static final EntityManager _instance = EntityManager._internal();
  factory EntityManager() => _instance;

  // Prefab stuff
  final _entitiesToAdd = <Entity>[];
  final _entitiesToRemove = <Entity>[];

  // NEW: Destroy animation system
  final _entitiesBeingDestroyed = <Entity>[];
  final _removedEntities = <Entity>[]; // Stores entities removed during gameplay
  final Map<Entity, Timer> _destroyTimers = {}; // Track destroy animation timers
  
  final Map<String, Entity> prefabs = {};
  final Map<String, dynamic> globalVariables = {};

  void addPrefab(String name, Entity entity) {
    entities[EntityType.actors]?.removeWhere((key, value) => value.name == entity.name);
    activeEntity = null;
    prefabs[name] = entity;
    notifyListeners();
  }

  void spawnPrefab(String name, Offset position) {
    final prefab = prefabs[name];
    if (prefab == null) return;

    final clone = prefab.copy();
    clone.position = position;
    spawnEntityLater(clone);
  }

  void addGlobalVariable(String name, dynamic value) {
    globalVariables[name] = value;
    notifyListeners();
  }

  EntityManager._internal() {
    _entities = {
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
    _activeEntity = null;
    _activeCamera = _entities[EntityType.cameras]!["mainCamera"] as CameraEntity;
  }

  Map<EntityType, Map<String, Entity>> get entities => _entities;
  
  Map<String, Entity> getEntitiesByType(EntityType type) {
    return _entities[type] ?? {};
  }
  
  List<Entity>? getLights() {
    return _entities[EntityType.lights]?.values.toList();
  }
  
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

  // For prefab
  void spawnEntityLater(Entity entity) {
    _entitiesToAdd.add(entity);
  }

  void removeEntityLater(Entity entity) {
    _entitiesToRemove.add(entity);
  }

  // NEW: Destroy entity with animation
  void destroyEntity(Entity entity) {
    // Check if entity is already being destroyed
    if (_entitiesBeingDestroyed.contains(entity)) {
      return;
    }

    // Add to being destroyed list
    _entitiesBeingDestroyed.add(entity);
    
    // Set destroy variable to trigger animation
    entity.setVariableXToValueY('destroy', true);

    // Get animation component to calculate destroy duration
    final animComp = entity.getComponent<AnimationControllerComponent>();
    Duration destroyDuration = Duration(milliseconds: 500); // Default fallback

    if (animComp != null) {
      final destroyTrack = animComp.getDestroyAnimationTrack();
      if (destroyTrack != null) {
        // Calculate total animation duration
        final frameCount = destroyTrack.frames.length;
        final fps = destroyTrack.fps;
        final totalDurationMs = (frameCount * 1000 / fps).round();
        destroyDuration = Duration(milliseconds: totalDurationMs);
      }
    }

    // Start timer to remove entity after animation completes
    _destroyTimers[entity] = Timer(destroyDuration, () {
      _finalizeEntityDestruction(entity);
    });

    log('Entity ${entity.name} destroy animation started, will be removed in ${destroyDuration.inMilliseconds}ms');
  }

  
  void _finalizeEntityDestruction(Entity entity) {
    // Remove from being destroyed list
    _entitiesBeingDestroyed.remove(entity);
    
    //remove timers
    _destroyTimers.remove(entity);

    
    String? entityKey;
    EntityType? entityType;
    
    for (var typeEntry in _entities.entries) {
      for (var entityEntry in typeEntry.value.entries) {
        if (entityEntry.value == entity) {
          entityKey = entityEntry.key;
          entityType = typeEntry.key;
          break;
        }
      }
      if (entityKey != null) break;
    }

    if (entityKey != null && entityType != null) {
      
      _removedEntities.add(entity);
      
      
      _entities[entityType]!.remove(entityKey);
      
     
      if (_activeEntity == entity) {
        _activeEntity = null;
      }
      
      log('Entity ${entity.name} has been destroyed and removed from scene');
      notifyListeners();
    }
  }

  
  void cancelEntityDestruction(Entity entity) {
    if (_entitiesBeingDestroyed.contains(entity)) {
      _entitiesBeingDestroyed.remove(entity);
      _destroyTimers[entity]?.cancel();
      _destroyTimers.remove(entity);
      entity.variables["destroy"] = false;
      log('Entity ${entity.name} destruction cancelled');
      notifyListeners();
    }
  }

  
  bool isEntityBeingDestroyed(Entity entity) {
    return _entitiesBeingDestroyed.contains(entity);
  }

  
  List<Entity> get entitiesBeingDestroyed => List.unmodifiable(_entitiesBeingDestroyed);

  
  List<Entity> get removedEntities => List.unmodifiable(_removedEntities);

  void update(Duration dt) {
    for (var type in _entities.values) {
      for (var entity in type.values) {
        if (entity.name == 'fire') {
          log('spawn and fire babyyyyy');
        }
        entity.update(dt);
      }
    }

    // Update entities being destroyed (they stay in scene during animation)
    for (var entity in _entitiesBeingDestroyed) {
      entity.update(dt);
    }

    // This is deferred for prefab to prevent conflicts and performance issues 
    // while adding and removing from the list of prefabs
    for (var e in _entitiesToAdd) {
      addEntity(EntityType.actors, e.name + Uuid().v4(), e);
    }
    _entitiesToAdd.clear();

    for (var e in _entitiesToRemove) {
      destroyEntity(e);
    }
    _entitiesToRemove.clear();
  }

  Entity? get activeEntity => _activeEntity;
  CameraEntity get activeCamera => _activeCamera!;

  set activeEntity(Entity? entity) {
    _activeEntity = entity;
    notifyListeners();
  }

  List<Entity> getAllEntitiesSortedByLayerNumber() {
    return _entities.values
        .expand((map) => map.values.whereNot((value) => value is CameraEntity))
        .toList()
      ..sort((a, b) => a.layerNumber.compareTo(b.layerNumber));
  }

  void setActiveEntityByTypeAndName(EntityType type, String name) {
    if (_entities[type]?.containsKey(name) == true) {
      _activeEntity = _entities[type]![name];
      notifyListeners();
    }
  }

  void setActiveEntityByName(String name) {
    for (var entry in entities.entries) {
      final entity = entry.value.values.firstWhereOrNull(
        (e) => e.name == name,
      );

      if (entity != null) {
        activeEntity = entity;
        notifyListeners();
        return;
      }
    }
  }

  void addComponentToActiveEntity(Component component) {
    activeEntity?.addComponent(component);
    notifyListeners();
  }

  // void removeEntity(EntityType type, String name) {
  //   final entity = _entities[type]?[name];
  //   if (entity != null) {
  //     destroyEntity(entity); // Use destroy system
  //   }
  // }

  Entity? getActorByName(String name) {
    return _entities[EntityType.actors]?.values.firstWhereOrNull((e)=>e.name == name);
  }

  List<Entity>? getActorByTag(String tag){
    return _entities[EntityType.actors]?.values.where((e)=>e.tag == tag).toList();
  }

  void switchCamera(String name) {
    final cam = _entities[EntityType.cameras]?[name];
    if (cam is CameraEntity) {
      _activeCamera = cam;
      notifyListeners();
    }
  }

  void reset() {
    // Cancel all destroy timers
    for (var timer in _destroyTimers.values) {
      timer.cancel();
    }
    _destroyTimers.clear();
    _entitiesBeingDestroyed.clear();

    // Restore removed entities back to the scene
    for (var removedEntity in _removedEntities) {
      // Reset entity state
      removedEntity.reset();
      removedEntity.variables["destroy"] = false;
      
      // Add back to entities map
      //final entityId = removedEntity.name + Uuid().v4();
      addEntity(EntityType.actors, removedEntity.name, removedEntity);
      
      log('Restored entity ${removedEntity.name} back to scene');
    }
    _removedEntities.clear();

    // Reset all active entities
    for (var type in _entities.values) {
      for (var entity in type.values) {
        entity.reset();
      }
    }

    log('EntityManager reset complete - all removed entities restored');
    notifyListeners();
  }

  bool hasEntity(String name) {
    for (var type in _entities.keys) {
      final entityThatStartWithname = _entities[type]?.values.firstWhereOrNull(
        (entity) => entity.name.startsWith(name)
      );
      if (entityThatStartWithname != null) {
        return true;
      }
    }
    return false;
  }

  void switchCameraFromEditorToGame() {
    final cameras = _entities[EntityType.cameras]?.values.cast<CameraEntity>();
    final cam = cameras?.firstWhere((cam) => !cam.isEditorCamera);

    if (cam != null) {
      _activeCamera = cam;
      notifyListeners();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'entities': _entities.map((type, entitiesMap) {
        return MapEntry(
          type.name,
          entitiesMap.map((id, entity) => MapEntry(id, entity.toJson())),
        );
      }),
      'globalVariables': globalVariables,
      'prefabs': prefabs.map((id, entity) => MapEntry(id, entity.toJson())),
      // Save removed entities so they can be restored
      'removedEntities': _removedEntities.map((entity) => entity.toJson()).toList(),
    };
  }

  void fromJson(Map<String, dynamic> json) {
    // Cancel any existing timers
    for (var timer in _destroyTimers.values) {
      timer.cancel();
    }
    _destroyTimers.clear();
    _entitiesBeingDestroyed.clear();

    _entities = {}; // Reset current entities

    final entitiesJson = json['entities'] as Map<String, dynamic>;
    for (final typeEntry in entitiesJson.entries) {
      final type = EntityType.values.firstWhere((e) => e.name == typeEntry.key);
      final entityMap = (typeEntry.value as Map<String, dynamic>).map(
        (id, entityJson) =>
            MapEntry(id, Entity.fromJson(entityJson as Map<String, dynamic>)),
      );
      _entities[type] = entityMap;
    }

    globalVariables.clear();
    globalVariables.addAll(
      (json['globalVariables'] as Map<String, dynamic>?) ?? {},
    );

    final prefabJson = json['prefabs'] as Map<String, dynamic>?;
    if (prefabJson != null) {
      prefabs.clear();
      for (final entry in prefabJson.entries) {
        prefabs[entry.key] = Entity.fromJson(entry.value);
      }
    }

    // Restore removed entities
    _removedEntities.clear();
    final removedEntitiesJson = json['removedEntities'] as List<dynamic>?;
    if (removedEntitiesJson != null) {
      for (final entityJson in removedEntitiesJson) {
        _removedEntities.add(Entity.fromJson(entityJson as Map<String, dynamic>));
      }
    }

    _activeEntity = null;

    // Restore the camera
    final cameraMap = _entities[EntityType.cameras];
    if (cameraMap != null && cameraMap.isNotEmpty) {
      final editorCamera = cameraMap.values
          .whereType<CameraEntity>()
          .firstWhere((cam) => cam.isEditorCamera, orElse: () => cameraMap.values.first as CameraEntity);
      _activeCamera = editorCamera;
    } else {
      // If no cameras exist at all, create one to avoid crash
      final fallbackCamera = CameraEntity(
        name: "mainCamera",
        position: const Offset(0, 100),
        rotation: 0,
        zoom: 1.0,
        isEditorCamera: true,
      );
      _entities[EntityType.cameras] = {"mainCamera": fallbackCamera};
      _activeCamera = fallbackCamera;
    }

    notifyListeners();
  }

  // NEW: Utility methods for debugging
  void logDestroyStatus() {
    log('=== DESTROY STATUS ===');
    log('Entities being destroyed: ${_entitiesBeingDestroyed.length}');
    for (var entity in _entitiesBeingDestroyed) {
      log('  - ${entity.name}');
    }
    log('Removed entities: ${_removedEntities.length}');
    for (var entity in _removedEntities) {
      log('  - ${entity.name}');
    }
    log('Active destroy timers: ${_destroyTimers.length}');
    log('======================');
  }
}