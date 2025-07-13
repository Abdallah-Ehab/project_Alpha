
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/apply_force_node_widget.dart';
import 'package:scratch_clone/physics_feature/data/rigid_body_component.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class ApplyForceNode extends NodeModel {
  double fx;
  double fy;

  ApplyForceNode({
    this.fx = 0.0,
    this.fy = 0.0,
    super.position = Offset.zero,
  }) : super(
          image: 'assets/icons/apply force.png',
          connectionPoints: [],
          color: Colors.deepPurple,
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

    final rb = activeEntity.getComponent<RigidBodyComponent>();
    if (rb == null) {
      return Result.failure(errorMessage: "RigidBodyComponent not found");
    }

    rb.applyForce(fx: fx, fy: fy);
    return Result.success(result: "Applied force fx=$fx, fy=$fy");
  }

  void setFx(double value) {
    fx = value;
    notifyListeners();
  }

  void setFy(double value) {
    fy = value;
    notifyListeners();
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: ApplyForceNodeWidget(node: this),
    );
  }

  @override
  ApplyForceNode copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    List<ConnectionPointModel>? connectionPoints,
    double? fx,
    double? fy,
  }) {
    final newNode = ApplyForceNode(
      fx: fx ?? this.fx,
      fy: fy ?? this.fy,
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
  ApplyForceNode copy() => copyWith();

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'ApplyForceNode';
    map['fx'] = fx;
    map['fy'] = fy;
    return map;
  }

  static ApplyForceNode fromJson(Map<String, dynamic> json) {
    final node = ApplyForceNode(
      fx: (json['fx'] as num).toDouble(),
      fy: (json['fy'] as num).toDouble(),
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
