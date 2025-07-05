import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/spawn_entity_node_widget/destroy_entity_node_with_name_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class DestroyEntityNodeWithName extends NodeModel {
  String entityName;

  DestroyEntityNodeWithName({
    this.entityName = '',
    super.position = Offset.zero,
  }) : super(
          image: 'assets/icons/DestroyEntityNode.png',
          width: 200,
          height: 100,
          color: Colors.red[900]!,
          connectionPoints: [],
        ) {
    connectionPoints = [
      ConnectConnectionPoint(
          position: Offset.zero, isTop: true, width: 20, ownerNode: this),
      ConnectConnectionPoint(
          position: Offset.zero, isTop: false, width: 20, ownerNode: this),
    ];
  }

  void setEntityName(String name) {
    entityName = name;
    notifyListeners();
  }

  @override
  Result execute([Entity? activeEntity]) {
    final entityManager = EntityManager();

    if (entityName.isEmpty) {
      return Result.failure(errorMessage: "No entity name specified to destroy.");
    }

    if (!entityManager.hasEntity(entityName)) {
      return Result.failure(errorMessage: "Entity '$entityName' not found.");
    }

    entityManager.removeEntity(EntityType.actors,entityName);
    log("Destroyed entity '$entityName'.");

    return Result.success(result: "Destroyed entity '$entityName'.");
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: DestroyEntityNodeWithNameWidget(node: this),
    );
  }

  @override
  DestroyEntityNodeWithName copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    List<ConnectionPointModel>? connectionPoints,
    String? entityName,
  }) {
    final newNode = DestroyEntityNodeWithName(
      entityName: entityName ?? this.entityName,
      position: position ?? this.position,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = null
      ..parent = null;

    newNode.connectionPoints = connectionPoints != null
        ? connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList()
        : this.connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList();

    return newNode;
  }

  @override
  DestroyEntityNodeWithName copy() => copyWith();

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'DestroyEntityNode';
    map['entityName'] = entityName;
    return map;
  }

  static DestroyEntityNodeWithName fromJson(Map<String, dynamic> json) {
    final node = DestroyEntityNodeWithName(
      entityName: json['entityName'] ?? '',
      position: OffsetJson.fromJson(json['position']),
    )
      ..id = json['id']
      ..isConnected = json['isConnected'] ?? false;

    node.connectionPoints = (json['connectionPoints'] as List)
        .map((e) => ConnectionPointModel.fromJson(e, node))
        .toList();

    return node;
  }
}
