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
  String entity1Name;
  String entity2Name;
  bool hasError;

  DetectCollisionNode({
    this.entity1Name = "",
    this.entity2Name = "",
    super.position = Offset.zero,
    this.hasError = false,
  }) : super(
          image: 'assets/icons/CollisionDetection.png',
          color: Colors.deepOrange,
          width: 160,
          height: 60,
          connectionPoints:[]
        ){
          connectionPoints =  [
            OutputConnectionPoint(position: Offset.zero, width: 50,ownerNode:this ),
          ];
        }

  void setEntities(String name1, String name2) {
    entity1Name = name1;
    entity2Name = name2;
    notifyListeners();
  }

  @override
  Result<bool> execute([Entity? activeEntity]) {
    final entity1 = EntityManager().getActorByName(entity1Name);
    final entity2 = EntityManager().getActorByName(entity2Name);

    if (entity1 == null || entity2 == null) {
      hasError = true;
      return Result.failure(errorMessage: "One or both entities not found.");
    }

    final collider1 = entity1.getComponent<ColliderComponent>();
    final collider2 = entity2.getComponent<ColliderComponent>();

    if (collider1 == null || collider2 == null) {
      hasError = true;
      return Result.failure(errorMessage: "Missing ColliderComponent.");
    }

    final rect1 = collider1.getRect(entity1);
    final rect2 = collider2.getRect(entity2);

    final bool isColliding = rect1.left < rect2.right &&
        rect1.right > rect2.left &&
        rect1.top < rect2.bottom &&
        rect1.bottom > rect2.top;

    return Result.success(result: isColliding);
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
    entity1Name: entity1Name,
    entity2Name: entity2Name,
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
  DetectCollisionNode copy() {
    return copyWith() as DetectCollisionNode;
  }

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'DetectCollisionNode';
    map['entity1Name'] = entity1Name;
    map['entity2Name'] = entity2Name;
    map['hasError'] = hasError;
    return map;
  }

static DetectCollisionNode fromJson(Map<String, dynamic> json) {
  final node = DetectCollisionNode(
    entity1Name: json['entity1Name'] ?? '',
    entity2Name: json['entity2Name'] ?? '',
    hasError: json['hasError'] ?? false,
    position: OffsetJson.fromJson(json['position'])
  )
    ..id = json['id']
    ..isConnected = json['isConnected'] ?? false;

  node.connectionPoints = (json['connectionPoints'] as List)
      .map((e) => ConnectionPointModel.fromJson(e, node))
      .toList();

  return node;
}

}
