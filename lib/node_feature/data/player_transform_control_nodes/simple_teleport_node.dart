
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/player_transform_node_widgets/simple_teleport_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class SimpleTeleportNode extends NodeModel {
  double dx;
  double dy;

  SimpleTeleportNode({
    this.dx = 0.0,
    this.dy = 0.0,
    super.position = Offset.zero,
  }) : super(
          image: 'assets/icons/TeleportNode.png',
          color: Colors.blue,
          width: 180,
          height: 140,
          connectionPoints: [],
        ) {
    connectionPoints = [
      ConnectConnectionPoint(position: Offset.zero, isTop: true, width: 30, ownerNode: this),
      ConnectConnectionPoint(position: Offset.zero, isTop: false, width: 30, ownerNode: this),
    ];
  }

  void setX(double x){
    dx = x ;
    notifyListeners();
  }

  void setY(double y){
    dy = y;
    notifyListeners();
  }

  @override
  Result execute([Entity? activeEntity]) {
    if (activeEntity == null) {
      return Result.failure(errorMessage: "No active entity");
    }

    activeEntity.teleport(dx: dx, dy: dy);
    return Result.success();
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: SimpleTeleportNodeWidget(nodeModel: this),
    );
  }

  @override
  @override
  SimpleTeleportNode copyWith({
    Offset? position,
    double? dx,
    double? dy,
    Color? color,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    List<ConnectionPointModel>? connectionPoints,
    double? width,
    double? height,
  }) {
    final newNode = SimpleTeleportNode(
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      position: position ?? this.position,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = null
      ..parent = null;

    newNode.connectionPoints = connectionPoints != null
        ? connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList()
        : this.connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList();

    // Optionally set width and height if needed, or ignore if not used in this subclass

    return newNode;
  }

  @override
  SimpleTeleportNode copy() => copyWith();

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'TeleportNodeManual';
    map['dx'] = dx;
    map['dy'] = dy;
    return map;
  }

  static SimpleTeleportNode fromJson(Map<String, dynamic> json) {
    final node = SimpleTeleportNode(
      dx: (json['dx'] as num?)?.toDouble() ?? 0,
      dy: (json['dy'] as num?)?.toDouble() ?? 0,
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
