import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/flow_control_node_widgets/set_variable_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class SetVariableNode extends NodeModel {
  String variableName;
  dynamic value;

  SetVariableNode(
      {this.variableName = "x", this.value = 0, super.position = Offset.zero})
      : super(
            image: 'assets/icons/setVariable.png',
            connectionPoints: [],
            color: Colors.orange,
            width: 200,
            height: 100) {
    connectionPoints = [
      ConnectConnectionPoint(
          position: Offset.zero, isTop: true, width: 20, ownerNode: this),
      ConnectConnectionPoint(
          position: Offset.zero, isTop: false, width: 20, ownerNode: this),
    ];
  }

  void setVariableName(String newName) {
    variableName = newName;
    notifyListeners();
  }

  void setValue(dynamic newValue) {
    value = newValue;
    notifyListeners();
  }

  @override
  Result execute([Entity? activeEntity,Duration? dt]) {
    if (activeEntity == null) {
      return Result.failure(errorMessage: "No active entity.");
    }

    if (!activeEntity.variables.containsKey(variableName)) {
      return Result.failure(
          errorMessage: "Variable '$variableName' is not declared.");
    }

    activeEntity.setVariableXToValueY(variableName, value);
    log('variable $variableName is set to $value');
    return Result.success(
        result: "Variable '$variableName' updated to $value.");
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: SetVariableNodeWidget(node: this),
    );
  }

  @override
SetVariableNode copyWith({
  Offset? position,
  Color? color,
  double? width,
  double? height,
  bool? isConnected,
  NodeModel? child,
  NodeModel? parent,
  String? variableName,
  dynamic value,
  List<ConnectionPointModel>? connectionPoints,
}) {
  final newNode = SetVariableNode(
    variableName: variableName ?? this.variableName,
    value: value ?? this.value,
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
  SetVariableNode copy() {
    return copyWith();
  }

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'SetVariableNode';
    map['variableName'] = variableName;
    map['value'] = value;
    return map;
  }

  static SetVariableNode fromJson(Map<String, dynamic> json) {
    final node = SetVariableNode(
      variableName: json['variableName'] as String,
      value: json['value'],
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
