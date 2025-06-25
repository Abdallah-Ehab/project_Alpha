

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/spawn_entity_node_widget/spawn_entity_node.dart';

class SpawnEntityNode extends NodeModel {
  String prefabName;

  SpawnEntityNode({
    required this.prefabName,
    required super.position,
    required super.color,
    required super.width,
    required super.height,
  }) : super(
          connectionPoints: [
            ConnectConnectionPoint(
                position: Offset.zero, isTop: true, width: 20),
            ConnectConnectionPoint(
                position: Offset.zero, isTop: false, width: 20),
          ],
        );

  void setPrefabName(String name) {
    prefabName = name;
    notifyListeners();
  }

  @override
  Result execute([Entity? activeEntity]) {
    final entityManager = EntityManager();

    if (activeEntity == null) {
      return Result.failure(
          errorMessage: "No active entity to spawn relative to.");
    }

    final position = activeEntity.position;

    entityManager.spawnPrefab(prefabName, position);

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
  SpawnEntityNode copy() {
    return SpawnEntityNode(
      prefabName: prefabName,
      position: position,
      color: color,
      width: width,
      height: height,
    )
      ..isConnected = isConnected
      ..parent = parent
      ..child = child;
  }

  @override
  NodeModel copyWith(
      {Offset? position,
      Color? color,
      double? width,
      double? height,
      bool? isConnected,
      NodeModel? child,
      NodeModel? parent}) {
    // TODO: implement copyWith
    throw UnimplementedError();
  }
}
