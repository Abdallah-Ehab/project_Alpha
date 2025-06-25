import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/flow_control/simple_condition_node_widget.dart';

class SimpleConditionNode extends NodeModel with HasOutput {
  dynamic firstOperand;
  dynamic secondOperand;
  String? comparisonOperator;

  SimpleConditionNode({
    super.position,
    required super.color,
    required super.width,
    required super.height,
  }) : super(
          connectionPoints: [
            OutputConnectionPoint(position: Offset.zero, width: 20),
          ],
        );

  @override
  Result<bool> execute([Entity? activeEntity]) {
    double? op1;
    double? op2;

    if (firstOperand == null || secondOperand == null || comparisonOperator == null) {
      return Result.failure(errorMessage: "Missing operand or operator");
    }

    if (activeEntity != null) {
      if (activeEntity.variables.containsKey(firstOperand)) {
        op1 = activeEntity.variables[firstOperand];
      }
      if (activeEntity.variables.containsKey(secondOperand)) {
        op2 = activeEntity.variables[secondOperand];
      }
    }

    op1 ??= double.tryParse(firstOperand.toString());
    op2 ??= double.tryParse(secondOperand.toString());

    switch (comparisonOperator) {
      case "==":
        return Result.success(result: op1 == op2);
      case ">":
        return Result.success(result: op1! > op2!);
      case "<":
        return Result.success(result: op1! < op2!);
      default:
        return Result.failure(errorMessage: "Invalid operator");
    }
  }

  void setFirstOperand(String value) {
    firstOperand = value;
    notifyListeners();
  }

  void setSecondOperand(String value) {
    secondOperand = value;
    notifyListeners();
  }

  void setOperator(String value) {
    comparisonOperator = value;
    notifyListeners();
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: SimpleConditionNodeWidget(node: this),
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
    return SimpleConditionNode(
      position: position ?? this.position,
      color: color ?? this.color,
      width: width ?? this.width,
      height: height ?? this.height,
    )
      ..firstOperand = firstOperand
      ..secondOperand = secondOperand
      ..comparisonOperator = comparisonOperator
      ..isConnected = isConnected ?? this.isConnected
      ..child = child ?? this.child
      ..parent = parent ?? this.parent;
  }

  @override
SimpleConditionNode copy() {
  return SimpleConditionNode(
    position: position,
    color: color,
    width: width,
    height: height,
  )
    ..firstOperand = firstOperand
    ..secondOperand = secondOperand
    ..comparisonOperator = comparisonOperator
    ..isConnected = isConnected
    ..child = child
    ..parent = parent
    ..output = output;
}
  
}
