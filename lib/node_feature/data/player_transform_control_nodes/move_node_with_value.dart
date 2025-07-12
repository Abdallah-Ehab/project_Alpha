
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/player_transform_node_widgets/move_node_with_value_widet.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class MoveNodeValueBased extends OutputNodeWithValue {
  MoveNodeValueBased({super.position = Offset.zero})
      : super(
          image: 'assets/icons/moveNode.png',
          color: Colors.blue,
          width: 200,
          height: 120,
          connectionPoints: [],
        ) {
    connectionPoints = [
      ValueConnectionPoint(
        position: Offset.zero,
        width: 30,
        valueIndex: 0,
        isLeft: true,
        ownerNode: this,
      ),
      ValueConnectionPoint(
        position: Offset.zero,
        width: 30,
        valueIndex: 1,
        isLeft: true,
        ownerNode: this,
      ),
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
    ];
  }

  @override
  Result execute([Entity? activeEntity,Duration? dt]) {
    if (activeEntity == null) {
      return Result.failure(errorMessage: "No active entity provided");
    }

    final dxPoint = connectionPoints[0] as ValueConnectionPoint;
    final dyPoint = connectionPoints[1] as ValueConnectionPoint;

    double? dx;
    double? dy;

    if (dxPoint.sourcePoint?.ownerNode != null) {
      final result = dxPoint.sourcePoint!.ownerNode.execute(activeEntity);
      if (result.errorMessage == null && result.result != null) {
        final value = result.result;
        if (value is List && dxPoint.sourcePoint!.valueIndex < value.length) {
          dx = (value[dxPoint.sourcePoint!.valueIndex])?.toDouble();
        } else if (value is num) {
          dx = value.toDouble();
        }
      }
    }

    if (dyPoint.sourcePoint?.ownerNode != null) {
      final result = dyPoint.sourcePoint!.ownerNode.execute(activeEntity);
      if (result.errorMessage == null && result.result != null) {
        final value = result.result;
        if (value is List && dyPoint.sourcePoint!.valueIndex < value.length) {
          dy = (value[dyPoint.sourcePoint!.valueIndex])?.toDouble();
        } else if (value is num) {
          dy = value.toDouble();
        }
      }
    }

    if (dx != null || dy != null) {
      activeEntity.move(x: dx, y: dy);
      return Result.success(
          result: "Moved by ${dx ?? 0} horizontally and ${dy ?? 0} vertically");
    }

    return Result.failure(errorMessage: "Missing dx or dy for MoveNode");
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: MoveNodeValueBasedWidget(nodeModel: this),
    );
  }

  @override
  @override
MoveNodeValueBased copyWith({
  Offset? position,
  Color? color,
  double? width,
  double? height,
  bool? isConnected,
  NodeModel? child,
  NodeModel? parent,
  List<ConnectionPointModel>? connectionPoints,
}) {
  final newNode = MoveNodeValueBased(
    position: position ?? this.position,
  )
    ..isConnected = isConnected ?? this.isConnected
    ..child = null // MoveNodeValueBased typically doesn't use this, but still matching signature
    ..parent = null;

  newNode.connectionPoints = connectionPoints != null
      ? connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList()
      : this.connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList();

  return newNode;
}


  @override
  MoveNodeValueBased copy() => copyWith();

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'MoveNodeValueBased';
    return map;
  }

  static MoveNodeValueBased fromJson(Map<String, dynamic> json) {
    final node = MoveNodeValueBased(
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
