import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/player_transform_node_widgets/flip_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class FlipNode extends NodeModel {
  FlipNode({super.position = Offset.zero})
      : super(
          image: 'assets/icons/flip.png',
          color: Colors.indigo,
          width: 180,
          height: 140,
          connectionPoints: [],
        ) {
    connectionPoints = [
      
      
      ConnectConnectionPoint(position: Offset.zero, isTop: true, width: 30, ownerNode: this),
      ConnectConnectionPoint(position: Offset.zero, isTop: false, width: 30, ownerNode: this),
    ];
  }

  @override
  Result execute([Entity? activeEntity]) {
    if (activeEntity == null) return Result.failure(errorMessage: "No active entity");

    final flipX = _extractBool(connectionPoints[1] as ValueConnectionPoint, activeEntity);
    final flipY = _extractBool(connectionPoints[2] as ValueConnectionPoint, activeEntity);

    if (flipX) {
      activeEntity.setWidth(activeEntity.widthScale * -1);
    }
    if (flipY) {
      activeEntity.setHeight(activeEntity.heigthScale * -1);
    }

    return Result.success();
  }

  bool _extractBool(ValueConnectionPoint point, Entity activeEntity) {
    final connectedNode = point.sourcePoint?.ownerNode;
    if (connectedNode == null) return false;

    final result = connectedNode.execute(activeEntity);
    if (result.errorMessage != null || result.result == null) return false;

    final val = result.result;
    if (val is bool) return val;
    if (val is num) return val != 0;
    return false;
  }

  @override
  Widget buildNode() => ChangeNotifierProvider.value(
        value: this,
        child: FlipNodeWidget(nodeModel: this),
      );

  @override
  FlipNode copyWith({
  Offset? position,
  Color? color,
  double? width,
  double? height,
  bool? isConnected,
  NodeModel? child,
  NodeModel? parent,
  List<ConnectionPointModel>? connectionPoints,
  double? x,
  double? y,
}) {
  final newNode = FlipNode()
    ..position = position ?? this.position
    ..isConnected = isConnected ?? this.isConnected
    ..child = null
    ..parent = null;

  newNode.connectionPoints = connectionPoints != null
      ? connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList()
      : this.connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList();

  return newNode;
}

  @override
  FlipNode copy() => copyWith();

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'FlipNode';
    return map;
  }

  static FlipNode fromJson(Map<String, dynamic> json) {
    final node = FlipNode(position: OffsetJson.fromJson(json['position']))
      ..id = json['id']
      ..isConnected = json['isConnected'] ?? false;

    node.connectionPoints = (json['connectionPoints'] as List)
        .map((e) => ConnectionPointModel.fromJson(e, node))
        .toList();

    return node;
  }
}
