import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/physics_related_node_widget/collision_detection_node_widget.dart';
import 'package:scratch_clone/physics_feature/data/collider_component.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class DetectCollisionNode extends InputNode {
  String tag;
  bool hasError;

  DetectCollisionNode({
    this.tag = "",
    super.position = Offset.zero,
    this.hasError = false,
  }) : super(
          image: 'assets/icons/detect collision.png',
          color: Colors.deepOrange,
          width: 160,
          height: 60,
          connectionPoints: [],
        ) {
    connectionPoints = [
      OutputConnectionPoint(position: Offset.zero, width: 50, ownerNode: this),
    ];
  }

  void setTag(String newTag) {
    tag = newTag;
    notifyListeners();
  }

  @override
  Result<bool> execute([Entity? activeEntity,Duration? dt]) {
    if (activeEntity == null) {
      hasError = true;
      return Result.failure(errorMessage: "No active entity.");
    }

    final targets = EntityManager().getActorByTag(tag);
    if (targets == null || targets.isEmpty) {
      hasError = true;
      return Result.success(result: false); // No targets = no collision
    }

    final collider1 = activeEntity.getComponent<ColliderComponent>();
    if (collider1 == null) {
      hasError = true;
      return Result.failure(errorMessage: "Active entity missing ColliderComponent.");
    }

    final rect1 = collider1.getRect(activeEntity);

    for (final target in targets) {
      if (target == activeEntity) continue; // skip self

      final collider2 = target.getComponent<ColliderComponent>();
      if (collider2 == null) continue;

      final rect2 = collider2.getRect(target);
      final isColliding = rect1.left < rect2.right &&
          rect1.right > rect2.left &&
          rect1.top < rect2.bottom &&
          rect1.bottom > rect2.top;

      if (isColliding) {
        return Result.success(result: true);
      }
    }

    return Result.success(result: false); // No collisions
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: DetectCollisionNodeWidget(nodeModel: this),
    );
  }

  @override
  NodeModel copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    List<ConnectionPointModel>? connectionPoints,
  }) {
    final newNode = DetectCollisionNode(
      tag: tag,
      position: position ?? this.position,
      hasError: hasError,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = null
      ..parent = null;

    newNode.connectionPoints = connectionPoints != null
        ? connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList()
        : this.connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList();

    return newNode;
  }

  @override
  DetectCollisionNode copy() => copyWith() as DetectCollisionNode;

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'DetectCollisionNode';
    map['tag'] = tag;
    map['hasError'] = hasError;
    return map;
  }

  static DetectCollisionNode fromJson(Map<String, dynamic> json) {
    final node = DetectCollisionNode(
      tag: json['tag'] ?? '',
      hasError: json['hasError'] ?? false,
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
