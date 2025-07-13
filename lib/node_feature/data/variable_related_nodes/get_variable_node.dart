import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/flow_control_node_widgets/get_variable_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class GetVariableNode extends InputNodeWithValue {
  String variableName;

  GetVariableNode({
    this.variableName = "x",
    super.position = Offset.zero,
  }) : super(
          image: 'assets/icons/getVariable.png',
          color: Colors.indigo,
          width: 180,
          height: 80,
          connectionPoints: [],
        ) {
    connectionPoints = [
      ValueConnectionPoint( // output
        position: Offset.zero,
        width: 30,
        isLeft: false,
        valueIndex: 0,
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

    final value = activeEntity.variables[variableName];
    return Result.success(result: value);
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: GetVariableNodeWidget(node:  this),
    );
  }

  @override
  GetVariableNode copyWith({
    Offset? position,
    String? variableName,
    List<ConnectionPointModel>? connectionPoints,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    double? width,
    double? height,
    Color? color,
  }) {
    final newNode = GetVariableNode(
      variableName: variableName ?? this.variableName,
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
  GetVariableNode copy() => copyWith();

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'GetVariableNode';
    map['variableName'] = variableName;
    return map;
  }

  static GetVariableNode fromJson(Map<String, dynamic> json) {
    final node = GetVariableNode(
      variableName: json['variableName'] as String,
      position: OffsetJson.fromJson(json['position']),
    );
    node.id = json['id'];
    node.isConnected = json['isConnected'] ?? false;
    node.connectionPoints = (json['connectionPoints'] as List)
        .map((e) => ConnectionPointModel.fromJson(e, node))
        .toList();
    return node;
  }
}
