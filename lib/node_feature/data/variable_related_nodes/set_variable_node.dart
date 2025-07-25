import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/flow_control_node_widgets/set_variable_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class SetVariableNode extends InputNodeWithValue {
  String variableName;
  dynamic value;

  SetVariableNode({
    this.variableName = "x",
    this.value,
    super.position = Offset.zero,
  }) : super(
          image: 'assets/icons/setVariable.png',
          color: Colors.orange,
          width: 200,
          height: 100,
          connectionPoints: [],
        ) {
    connectionPoints = [
      ConnectConnectionPoint(
          position: Offset.zero, isTop: true, width: 20, ownerNode: this),
      ConnectConnectionPoint(
          position: Offset.zero, isTop: false, width: 20, ownerNode: this),
      ValueConnectionPoint( // value input
        position: Offset.zero,
        isLeft: true,
        width: 30,
        ownerNode: this,
        valueIndex: 0,
      ),
    ];
  }

  void setVariableName(String newName) {
    variableName = newName;
    notifyListeners();
  }

  void setValue(dynamic newValue) { // <-- added setter
    value = newValue;
    notifyListeners();
  }

  @override
  Result execute([Entity? activeEntity, Duration? dt]) {
    if (activeEntity == null) {
      return Result.failure(errorMessage: "No active entity.");
    }

    final inputPoint = connectionPoints[2] as ValueConnectionPoint;
    dynamic finalValue;

    if (inputPoint.sourcePoint?.ownerNode != null) {
      final sourceResult = inputPoint.sourcePoint!.ownerNode.execute(activeEntity);
      if (sourceResult.errorMessage != null) {
        return Result.failure(errorMessage: sourceResult.errorMessage!);
      }
      finalValue = sourceResult.result;
      log('value is $value');
    } else {
      finalValue = value; // fallback to local field
    }

    if (!activeEntity.variables.containsKey(variableName)) {
      return Result.failure(
          errorMessage: "Variable '$variableName' is not declared.");
    }

    activeEntity.setVariableXToValueY(variableName, finalValue);
    return Result.success(result: "Variable '$variableName' updated.");
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
    String? variableName,
    dynamic value,
    List<ConnectionPointModel>? connectionPoints,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    double? width,
    double? height,
    Color? color,
  }) {
    final newNode = SetVariableNode(
      variableName: variableName ?? this.variableName,
      value: value ?? this.value,
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
  SetVariableNode copy() => copyWith();

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'SetVariableNode';
    map['variableName'] = variableName;
    map['value'] = value; // <-- save value
    return map;
  }

  static SetVariableNode fromJson(Map<String, dynamic> json) {
    final node = SetVariableNode(
      variableName: json['variableName'] as String,
      value: json['value'], // <-- restore value
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
