import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/player_transform_node_widgets/move_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

// Todo the move node will have 2 connection points (connect, connect) it doesn't have an input or output it will just be connected
class MoveNode extends NodeModel {
  double x;
  double y;

  MoveNode({
    this.x = 0.0,
    this.y = 0.0,
    super.position = Offset.zero
  }) : super(
    image: 'assets/icons/moveNode.png',
    connectionPoints: [],
    color: Colors.blue,
    width: 200,
    height: 100,
  ) {
    connectionPoints = [
      ConnectConnectionPoint(position: Offset.zero, isTop: true, width: 20, ownerNode: this),
      ConnectConnectionPoint(position: Offset.zero, isTop: false, width: 20, ownerNode: this),
    ];
  }

  @override
  Result<String> execute([Entity? activeEntity,Duration? dt]) {
    if (activeEntity == null) {
      return Result.failure(errorMessage: "Active entity not provided");
    }
    if (activeEntity.name == 'fire') {
      log("Iam fire and Iam moving baby");
    }
    activeEntity.move(x: x, y: y);

    return Result.success(
        result: "Moved by $x horizontally and by $y vertically");
  }

  void setX(double value) {
    x = value;
    notifyListeners();
  }

  void setY(double value) {
    y = value;
    notifyListeners();
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: MoveNodeWidget(
        node: this,
      ),
    );
  }

  @override
MoveNode copyWith({
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
  final newNode = MoveNode(
    x: x ?? this.x,
    y: y ?? this.y,
  )
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
  MoveNode copy() {
    final moveNodeCopy = copyWith();
    return moveNodeCopy;
  }

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'MoveNode';
    map['x'] = x;
    map['y'] = y;
    return map;
  }

static MoveNode fromJson(Map<String, dynamic> json) {
  final moveNode = MoveNode(
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    position: OffsetJson.fromJson(json['position'])
  )
    ..id = json['id']
    ..isConnected = json['isConnected'] ?? false;

  moveNode.connectionPoints = (json['connectionPoints'] as List)
      .map((e) => ConnectionPointModel.fromJson(e, moveNode))
      .toList();

  return moveNode;
}

}



