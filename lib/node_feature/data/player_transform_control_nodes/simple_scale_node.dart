import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/player_transform_node_widgets/simple_scale_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class SetScaleNode extends NodeModel {
  double widthScale;
  double heightScale;

  SetScaleNode({
    this.widthScale = 1.0,
    this.heightScale = 1.0,
    super.position,
  }) : super(
          image: 'assets/icons/scaleNode.png',
          color: Colors.purple,
          width: 160,
          height: 60,
          connectionPoints: [],
        ) {
    connectionPoints = [
    
      ConnectConnectionPoint(position: Offset.zero, isTop: true, width: 30, ownerNode: this),
      ConnectConnectionPoint(position: Offset.zero, isTop: false, width: 30, ownerNode: this),
    ];
  }

  @override
  Result execute([Entity? activeEntity,Duration? dt]) {
    if (activeEntity == null) {
      return Result.failure(errorMessage: "No active entity.");
    }
    activeEntity.setWidth(widthScale);
    activeEntity.setHeight(heightScale);
    return Result.success();
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: SimpleScaleNodeWidget(nodeModel : this)
    );
  }

  @override
  SetScaleNode copyWith({
  Offset? position,
  Color? color,
  double? width,
  double? height,
  bool? isConnected,
  NodeModel? child,
  NodeModel? parent,
  List<ConnectionPointModel>? connectionPoints,
}) {
  final newNode = SetScaleNode(
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
  SetScaleNode copy() => copyWith();

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'SetScaleNode';
    map['widthScale'] = widthScale;
    map['heightScale'] = heightScale;
    return map;
  }

  static SetScaleNode fromJson(Map<String, dynamic> json) {
    return SetScaleNode(
      widthScale: json['widthScale'] ?? 1.0,
      heightScale: json['heightScale'] ?? 1.0,
      position: OffsetJson.fromJson(json['position']),
    )..id = json['id']
     ..isConnected = json['isConnected'] ?? false;
  }
}
