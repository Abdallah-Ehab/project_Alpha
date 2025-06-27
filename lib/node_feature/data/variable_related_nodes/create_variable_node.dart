

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/variable_related_node_widgets/create_variable_node_widget.dart';


// //Todo more like a block it just creates a global variable it's not considered as a node no input, output, or connection
class CreateVariableNode extends NodeModel {
  String variableName;
  dynamic value;

  CreateVariableNode({
    this.variableName = "x",
    required this.value,
    required super.position,
    required super.color,
    required super.width,
    required super.height,
  }) : super(
          connectionPoints: [
            ConnectConnectionPoint(position: Offset.zero, isTop: true, width: 20),
            ConnectConnectionPoint(position: Offset.zero, isTop: false, width: 20),
          ],
        );

  void setVariableName(String newName) {
    variableName = newName;
    notifyListeners();
  }

  void setValue(dynamic newValue) {
    value = newValue;
    notifyListeners();
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: CreateVariableNodeWidget(node: this),
    );
  }

  @override
  Result execute([Entity? activeEntity]) {
    if (activeEntity == null) {
      return Result.failure(errorMessage: "No active entity.");
    }

    activeEntity.addVariable(name: variableName, value: value);
    return Result.success(result: "Variable '$variableName' set to $value.");
  }

  @override
  CreateVariableNode copyWith({
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
    return CreateVariableNode(
      variableName: variableName ?? this.variableName,
      value: value ?? this.value,
      position: position ?? this.position,
      color: color ?? this.color,
      width: width ?? this.width,
      height: height ?? this.height,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = child ?? this.child?.copy()
      ..parent = parent ?? this.parent?.copy()
      ..connectionPoints = connectionPoints ??
          List<ConnectionPointModel>.from(this.connectionPoints.map((cp) => cp.copy()));
  }

  @override
  CreateVariableNode copy() {
    return copyWith(
      position: position,
      color: color,
      width: width,
      height: height,
      isConnected: isConnected,
      child: child?.copy(),
      parent: parent?.copy(),
      variableName: variableName,
      value: value,
      connectionPoints: List<ConnectionPointModel>.from(
        connectionPoints.map((cp) => cp.copy()),
      ),
    );
  }
}
