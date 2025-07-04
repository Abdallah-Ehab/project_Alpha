import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/player_transform_node_widgets/teleport_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class TeleportNode extends OutputNodeWithValue {
  TeleportNode({super.position = Offset.zero})
      : super(
          image: 'assets/icons/TeleportNode.png',
          color: Colors.orange,
          width: 180,
          height: 160,
          connectionPoints: [],
        ) {
    connectionPoints = [
      InputConnectionPoint(position: Offset.zero, width: 30, ownerNode: this),
      ValueConnectionPoint(
          position: Offset.zero,
          width: 30,
          valueIndex: 0,
          isLeft: true,
          ownerNode: this),
      ValueConnectionPoint(
          position: Offset.zero,
          width: 30,
          valueIndex: 1,
          isLeft: true,
          ownerNode: this),
      ConnectConnectionPoint(
          position: Offset.zero, isTop: true, width: 30, ownerNode: this),
      ConnectConnectionPoint(
          position: Offset.zero, isTop: false, width: 30, ownerNode: this),
    ];
  }

  @override
  Result execute([Entity? activeEntity]) {
    if (activeEntity == null) {
      return Result.failure(errorMessage: "No active entity");
    }

    Result? inputResult;
    if (input != null) {
      inputResult = input!.execute(activeEntity);
      if (inputResult.errorMessage != null) return inputResult;
    } else {
      inputResult = Result.success(result: null);
    }

    final dxPoint = connectionPoints[1] as ValueConnectionPoint;
    final dyPoint = connectionPoints[2] as ValueConnectionPoint;

    final sourceNode = dxPoint.sourcePoint?.ownerNode;
    if (sourceNode == null) {
      return Result.failure(errorMessage: "No source node for teleport dx");
    }

    final result = sourceNode.execute(activeEntity);
    if (result.errorMessage != null || result.result == null) {
      return Result.failure(errorMessage: result.errorMessage ?? "Null result");
    }

    final value = result.result;
    double? dx, dy;

    if (value is Offset) {
      dx = dxPoint.sourcePoint?.valueIndex == 0 ? value.dx : value.dy;
      dy = dyPoint.sourcePoint?.valueIndex == 1 ? value.dy : value.dx;
    }

    if (dx == null || dy == null) {
      return Result.failure(errorMessage: "dx or dy could not be extracted");
    }
    return Result.success();
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: TeleportNodeWidget(nodeModel: this),
    );
  }

  @override
TeleportNode copyWith({
  Offset? position,
  Color? color,
  double? width,
  double? height,
  bool? isConnected,
  NodeModel? child,
  NodeModel? parent,
  List<ConnectionPointModel>? connectionPoints,
}) {
  final newNode = TeleportNode(position: position ?? this.position)
    ..isConnected = isConnected ?? this.isConnected
    ..child = null
    ..parent = null
    ..input = null;

  newNode.connectionPoints = connectionPoints != null
      ? connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList()
      : this.connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList();

  return newNode;
}

  @override
  TeleportNode copy() {
    return copyWith();
  }

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'TeleportNode';
    return map;
  }

  static TeleportNode fromJson(Map<String, dynamic> json) {
    final node = TeleportNode(
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
