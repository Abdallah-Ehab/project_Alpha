import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/flow_control_node_widgets/else_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class ElseNode extends InputOutputNode {
  ElseNode({
    super.position,
  }) : super(
    image: 'assets/icons/ELSE.png',
    color: Colors.blue,
    width: 200,
    height: 200,
    connectionPoints: [],
  ) {
    connectionPoints = [
      OutputConnectionPoint(position: Offset.zero, width: 50, ownerNode: this),
      ConnectConnectionPoint(position: Offset.zero, isTop: true, width: 50, ownerNode: this),
      ConnectConnectionPoint(position: Offset.zero, isTop: false, width: 50, ownerNode: this),
    ];
  }



  @override
  Result execute([Entity? activeEntity]) {
    if (output != null) {
      final statementResult = output!.execute(activeEntity);
      if (statementResult.errorMessage != null) {
        log('else is executed');
        return Result.failure(errorMessage: statementResult.errorMessage);
      }
    }
    return Result.success(result: null); // Indicate successful execution
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: ElseNodeWidget(nodeModel: this),
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
  NodeModel? output,
  List<ConnectionPointModel>? connectionPoints,
}) {
  final newNode = ElseNode(
    position: position ?? this.position,
  );

  newNode.isConnected = isConnected ?? this.isConnected;
  newNode.child = null;
  newNode.parent = null;
  newNode.output = null;

  newNode.connectionPoints = connectionPoints ??
      this.connectionPoints
          .map((cp) => cp.copyWith(ownerNode: newNode))
          .toList();

  return newNode;
}

  @override
  ElseNode copy() {
    return copyWith() as ElseNode;
  }

  static ElseNode fromJson(Map<String, dynamic> json) {
    final node = ElseNode(
      position: OffsetJson.fromJson(json['position']),
    )
      ..id = json['id']
      ..width = (json['width'] as num).toDouble()
      ..height = (json['height'] as num).toDouble()
      ..isConnected = json['isConnected'] as bool;
      node.connectionPoints = (json['connectionPoints'] as List)
          .map((e) => e['isTop'] == null
              ? ConnectionPointModel.fromJson(e,node)
              : ConnectionPointModel.fromJson(e,node))
          .toList();

    return node;
  }

  /// ✅ TO JSON
  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'ElseNode';
    return map;
  }
}