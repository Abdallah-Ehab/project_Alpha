import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/variable_related_node_widgets/declare_variable_node_widget.dart';

class DeclareVariableNode extends NodeModel {
  String variableName;
  dynamic value;

  DeclareVariableNode({
    this.variableName = "x",
    this.value = 0,

    
  }) : super(
          connectionPoints: [],
          position: Offset.zero,color: Colors.orange,width: 200,height: 100
        );

    static DeclareVariableNode fromJson(Map<String, dynamic> json) => DeclareVariableNode(
        variableName: json['variableName'] as String,
        value: json['value'],
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
    return Result.success(result: "Variable '$variableName' updated to $value.");
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: DeclareVarableNodeWidget(node: this),
    );
  }

  @override
  DeclareVariableNode copyWith({
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
    return DeclareVariableNode(
      variableName: variableName ?? this.variableName,
      value: value ?? this.value,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = child ?? this.child?.copy()
      ..parent = parent ?? this.parent?.copy()
      ..connectionPoints = connectionPoints ??
          List<ConnectionPointModel>.from(this.connectionPoints.map((cp) => cp.copy()));
  }

  @override
  DeclareVariableNode copy() {
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




