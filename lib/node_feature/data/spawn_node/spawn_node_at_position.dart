import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/spawn_entity_node_widget/spawn_node_at_position_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class SpawnAtNode extends NodeModel {
  double x;
  double y;
  String prefabName;
  SpawnAtNode({
    this.prefabName = '',
    this.x = 0,
    this.y = 0,
    super.position = Offset.zero,
    
  }) : super(
          image: 'assets/icons/spawn.png',
          color: Colors.green,
          width: 200,
          height: 160,
          connectionPoints: []
        ) {
    connectionPoints = [
      // Flow control
      ConnectConnectionPoint(
        position: Offset.zero,
        isTop: true,
        width: 30,
        ownerNode: this,
      ),
      ConnectConnectionPoint(
        position: Offset.zero,
        isTop: false,
        width: 30,
        ownerNode: this,
      ),

      // Value inputs (x, y)
      ValueConnectionPoint(
        position: Offset(0, 60),
        isLeft: true,
        ownerNode: this, valueIndex: 0, width: 30,
      ),
      ValueConnectionPoint(
        position: Offset(0, 100),
        isLeft: true,
        ownerNode: this, valueIndex: 1, width: 30,
      ),
    ];
  }

  @override
  Result execute([Entity? activeEntity]) {
    final valX = _evaluate(connectionPoints[2] as ValueConnectionPoint, x, activeEntity);
    final valY = _evaluate(connectionPoints[3] as ValueConnectionPoint, y, activeEntity);
    
        if (prefabName != null) {
      EntityManager().spawnPrefabAtPosition(prefabName, Offset(valX, valY));
    }

    return Result.success();
  }

  double _evaluate(ValueConnectionPoint point, double fallback, Entity? entity) {
    final connected = point.sourcePoint?.ownerNode;
    if (connected == null) return fallback;

    final result = connected.execute(entity);
    if (result.result is num) return (result.result as num).toDouble();

    return fallback;
  }

  @override
  Widget buildNode() => ChangeNotifierProvider.value(
        value: this,
        child: SpawnAtNodeWidget(node: this),
      );

  @override
  SpawnAtNode copyWith({
    Offset? position,
    double? x,
    double? y,
    List<ConnectionPointModel>? connectionPoints,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    double? width,
    double? height,
    Color? color,
  }) {
    final newNode = SpawnAtNode(
      position: position ?? this.position,
      x: x ?? this.x,
      y: y ?? this.y,
    )..isConnected = isConnected ?? this.isConnected;

    newNode.connectionPoints = connectionPoints != null
        ? connectionPoints.map((p) => p.copyWith(ownerNode: newNode)).toList()
        : this.connectionPoints.map((p) => p.copyWith(ownerNode: newNode)).toList();

    return newNode;
  }

  @override
  SpawnAtNode copy() => copyWith();

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'SpawnAtNode';
    map['x'] = x;
    map['y'] = y;
    return map;
  }

  static SpawnAtNode fromJson(Map<String, dynamic> json) {
    final node = SpawnAtNode(
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      position: OffsetJson.fromJson(json['position']),
    )..id = json['id'];

    node.isConnected = json['isConnected'] ?? false;
    node.connectionPoints = (json['connectionPoints'] as List)
        .map((e) => ConnectionPointModel.fromJson(e, node))
        .toList();

    return node;
  }
}
