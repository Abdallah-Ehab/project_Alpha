import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/spawn_entity_node_widget/destroy_entity_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class DestroyEntityNode extends NodeModel {
  DestroyEntityNode({super.position = Offset.zero})
      : super(
          image: 'assets/icons/destroyNode.png',
          color: Colors.redAccent,
          width: 160,
          height: 100,
          connectionPoints: [],
        ) {
    connectionPoints = [
      ConnectConnectionPoint(position: Offset.zero, isTop: true, width: 30, ownerNode: this),
      ConnectConnectionPoint(position: Offset.zero, isTop: false, width: 30, ownerNode: this),
    ];
  }

  @override
  Result execute([Entity? activeEntity,Duration? dt]) {
    if (activeEntity == null) {
      return Result.failure(errorMessage: "No active entity to destroy.");
    }

    EntityManager().removeEntityLater(activeEntity);
    return Result.success(result: "${activeEntity.name} will be destroyed");
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: DestroyEntityNodeWidget(node: this),
    );
  }

  @override
  DestroyEntityNode copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    List<ConnectionPointModel>? connectionPoints,
  }) {
    final newNode = DestroyEntityNode(position: position ?? this.position)
      ..isConnected = isConnected ?? this.isConnected
      ..child = null
      ..parent = null;

    newNode.connectionPoints = connectionPoints != null
        ? connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList()
        : this.connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList();

    return newNode;
  }

  @override
  DestroyEntityNode copy() => copyWith();

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'DestroyEntityNode';
    return map;
  }

  static DestroyEntityNode fromJson(Map<String, dynamic> json) {
    final node = DestroyEntityNode(position: OffsetJson.fromJson(json['position']))
      ..id = json['id']
      ..isConnected = json['isConnected'] ?? false;

    node.connectionPoints = (json['connectionPoints'] as List)
        .map((e) => ConnectionPointModel.fromJson(e, node))
        .toList();

    return node;
  }
}
