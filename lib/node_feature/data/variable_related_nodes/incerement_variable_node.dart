import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/variable_related_node_widgets/incerement_variable_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class IncrementVariableNode extends NodeModel {
  String variableName;

  IncrementVariableNode({
    this.variableName = "x",
    super.position = Offset.zero,
  }) : super(
          image: 'assets/icons/addNode.png',
          color: Colors.green,
          width: 180,
          height: 120,
          connectionPoints: [],
        ) {
    connectionPoints = [
      ConnectConnectionPoint(
        position: Offset.zero,
        isTop: true,
        width: 20,
        ownerNode: this,
      ),
      ConnectConnectionPoint(
        position: Offset.zero,
        isTop: false,
        width: 20,
        ownerNode: this,
      ),
    ];
  }

  void setVariableName(String newName) {
    variableName = newName;
    notifyListeners();
  }

  @override
  Result execute([Entity? activeEntity, Duration? dt]) {
    if (activeEntity == null) {
      return Result.failure(errorMessage: "No active entity.");
    }

    if (!activeEntity.variables.containsKey(variableName)) {
      return Result.failure(
          errorMessage: "Variable '$variableName' is not declared.");
    }

    final currentValue = activeEntity.variables[variableName];
    if (currentValue is num) {
      activeEntity.setVariableXToValueY(variableName, currentValue + 1);
      return Result.success(result: "Variable '$variableName' incremented.");
    } else {
      return Result.failure(
          errorMessage: "Variable '$variableName' is not a number.");
    }
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: IncrementVariableNodeWidget(
        node: this,
        
      ),
    );
  }

  @override
  IncrementVariableNode copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    List<ConnectionPointModel>? connectionPoints,
  }) {
    final newNode = IncrementVariableNode(
      variableName: variableName,
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
  IncrementVariableNode copy() => copyWith();

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'IncrementVariableNode';
    map['variableName'] = variableName;
    return map;
  }

  static IncrementVariableNode fromJson(Map<String, dynamic> json) {
    final node = IncrementVariableNode(
      variableName: json['variableName'] as String,
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
