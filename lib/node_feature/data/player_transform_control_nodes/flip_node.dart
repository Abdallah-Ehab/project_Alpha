import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/player_transform_node_widgets/flip_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class SimpleFlipNode extends NodeModel {
  bool flipX;
  bool flipY;

  SimpleFlipNode({
    this.flipX = false,
    this.flipY = false,
    super.position = Offset.zero,
  }) : super(
          image: 'assets/icons/flip.png',
          color: Colors.deepPurple,
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

    if (flipX) {
      activeEntity.setWidth(activeEntity.widthScale * -1);
    }
    if (flipY) {
      activeEntity.setHeight(activeEntity.heigthScale * -1);
    }

    return Result.success();
  }

  @override
  Widget buildNode() => ChangeNotifierProvider.value(
        value: this,
        child: SimpleFlipNodeWidget(node: this),
      );
  
  void setFlipX(bool value){
    flipX = value;
    notifyListeners();
  }

   void setFlipY(bool value){
    flipY = value;
    notifyListeners();
  }

  @override
SimpleFlipNode copyWith({
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
  bool? flipX,
  bool? flipY,
}) {
  final newNode = SimpleFlipNode(
    flipX: flipX ?? this.flipX,
    flipY: flipY ?? this.flipY,
    position: position ?? this.position,
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
  NodeModel copy() => copyWith();

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'SimpleFlipNode';
    map['flipX'] = flipX;
    map['flipY'] = flipY;
    return map;
  }

  static SimpleFlipNode fromJson(Map<String, dynamic> json) {
    final node = SimpleFlipNode(
      flipX: json['flipX'] ?? false,
      flipY: json['flipY'] ?? false,
      position: OffsetJson.fromJson(json['position']),
    )..id = json['id']
     ..isConnected = json['isConnected'] ?? false;

    node.connectionPoints = (json['connectionPoints'] as List)
        .map((e) => ConnectionPointModel.fromJson(e, node))
        .toList();

    return node;
  }
}
