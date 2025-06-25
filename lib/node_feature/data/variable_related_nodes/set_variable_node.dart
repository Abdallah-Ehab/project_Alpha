import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/variable_related_node_widgets/set_variable_node_widget.dart';

class SetVariableNode extends NodeModel {
  String variableName;
  dynamic value;

  SetVariableNode({
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
  Result execute([Entity? activeEntity]) {
    if (activeEntity == null) {
      return Result.failure(errorMessage: "No active entity.");
    }

    if (!activeEntity.variables.containsKey(variableName)) {
      return Result.failure(errorMessage: "Variable '$variableName' is not declared.");
    }

    activeEntity.setVariableXToValueY( variableName, value);
    return Result.success(result: "Variable '$variableName' updated to $value.");
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: SetVariableNodeWidget(node: this),
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
    return SetVariableNode(
      variableName: variableName,
      value: value,
      position: position ?? this.position,
      color: color ?? this.color,
      width: width ?? this.width,
      height: height ?? this.height,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = child ?? this.child
      ..parent = parent ?? this.parent;
  }
  
  @override
SetVariableNode copy() {
  return SetVariableNode(
    variableName: variableName,
    value: value,
    position: position,
    color: color,
    width: width,
    height: height,
  )
    ..isConnected = isConnected
    ..child = child
    ..parent = parent;
}

}
