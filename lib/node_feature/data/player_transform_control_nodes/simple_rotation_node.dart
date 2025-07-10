import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/player_transform_node_widgets/simple_rotation_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class SetRotationNode extends NodeModel {
  double rotation;

  SetRotationNode({
    this.rotation = 0.0,
    super.position,
  }) : super(
          image: 'assets/icons/rotateNode.png',
          color: Colors.orange,
          width: 160,
          height: 60,
          connectionPoints: [],
        ) {
    connectionPoints = [
      ConnectConnectionPoint(
          position: Offset.zero, isTop: true, width: 30, ownerNode: this),
      ConnectConnectionPoint(
          position: Offset.zero, isTop: false, width: 30, ownerNode: this),
    ];
  }

  @override
  Result execute([Entity? activeEntity,Duration? dt]) {
    if (activeEntity == null) {
      return Result.failure(errorMessage: "No active entity.");
    }
    activeEntity.rotate(rotation);
    return Result.success();
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
        value: this, child: SimpleRotationNodeWidget(nodeModel: this));
  }

  @override
  SetRotationNode copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    List<ConnectionPointModel>? connectionPoints,
  }) {
    final node = SetRotationNode(
      position: position ?? this.position,
    )..isConnected = isConnected ?? this.isConnected;

    node.connectionPoints = connectionPoints != null
        ? connectionPoints.map((cp) => cp.copyWith(ownerNode: node)).toList()
        : this
            .connectionPoints
            .map((cp) => cp.copyWith(ownerNode: node))
            .toList();

    return node;
  }

  @override
  SetRotationNode copy() => copyWith();

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'SetRotationNode';
    map['rotation'] = rotation;
    return map;
  }

  static SetRotationNode fromJson(Map<String, dynamic> json) {
    return SetRotationNode(
      rotation: json['rotation'] ?? 0.0,
      position: OffsetJson.fromJson(json['position']),
    )
      ..id = json['id']
      ..isConnected = json['isConnected'] ?? false;
  }
}
