import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/spawn_entity_node_widget/spawn_entity_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class SpawnEntityNode extends NodeModel {
  String prefabName;
  bool isOnce;
  bool hasSpawned;

  SpawnEntityNode({
    this.prefabName = '',
    this.isOnce = false,
    this.hasSpawned  =false,
    super.position = Offset.zero,
  }) : super(
          image: 'assets/icons/SpawnEntityNode.png',
          width: 200,
          height: 200,
          color: Colors.black,
          connectionPoints: [],
        ) {
    connectionPoints = [
      ConnectConnectionPoint(
          position: Offset.zero, isTop: true, width: 20, ownerNode: this),
      ConnectConnectionPoint(
          position: Offset.zero, isTop: false, width: 20, ownerNode: this),
    ];
  }

  void setPrefabName(String name) {
    prefabName = name;
    notifyListeners();
  }

  void setIsOnce(bool value){
    isOnce = value;
    notifyListeners();
  }

  @override
  Result execute([Entity? activeEntity,Duration? dt]) {
    final entityManager = EntityManager();

    if (isOnce && hasSpawned) {
      return Result.success(); // Skip execution
    }

    if (activeEntity == null) {
      return Result.failure(
          errorMessage: "No active entity to spawn relative to.");
    }

    final position = activeEntity.position;

    entityManager.spawnPrefab(prefabName);
    hasSpawned = true;

    log("Spawned prefab '$prefabName' at $position.");
    return Result.success(result: "Spawned prefab '$prefabName' at $position.");
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: SpawnEntityNodeWidget(node: this),
    );
  }

  @override
  SpawnEntityNode copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    List<ConnectionPointModel>? connectionPoints,
    String? prefabName,
    bool? isOnce,
    
  }) {
    final newNode = SpawnEntityNode(
      prefabName: prefabName ?? this.prefabName,
      position: position ?? this.position,
      isOnce: isOnce ?? this.isOnce
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = null
      ..parent = null;

    newNode.connectionPoints = connectionPoints != null
        ? connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList()
        : this
            .connectionPoints
            .map((cp) => cp.copyWith(ownerNode: newNode))
            .toList();

    return newNode;
  }

  @override
  SpawnEntityNode copy() {
    return copyWith();
  }

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'SpawnEntityNode';
    map['prefabName'] = prefabName;
    map['isOnce'] = isOnce;
    return map;
  }

  static SpawnEntityNode fromJson(Map<String, dynamic> json) {
    final node = SpawnEntityNode(
        prefabName: json['prefabName'] ?? '',
        isOnce: json['isOnce'],
        hasSpawned: false,
        position: OffsetJson.fromJson(json['position']))
      ..id = json['id']
      ..isConnected = json['isConnected'] ?? false;

    node.connectionPoints = (json['connectionPoints'] as List)
        .map((e) => ConnectionPointModel.fromJson(e, node))
        .toList();

    return node;
  }
}
