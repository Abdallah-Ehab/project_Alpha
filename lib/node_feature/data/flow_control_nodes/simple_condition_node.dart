import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/flow_control_node_widgets/simple_condition_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class SimpleConditionNode extends NodeModel with HasOutput {
  dynamic firstOperand;
  dynamic secondOperand;
  String? comparisonOperator;

  SimpleConditionNode({
    super.position,
    this.firstOperand,
    this.secondOperand,
    this.comparisonOperator,
  }) : super(
          color: Colors.yellow,
          width: 200,
          height: 100,
          connectionPoints: [
            OutputConnectionPoint(position: Offset.zero, width: 20),
          ],
        );

  @override
  Result<bool> execute([Entity? activeEntity]) {
    double? op1;
    double? op2;

    if (firstOperand == null ||
        secondOperand == null ||
        comparisonOperator == null) {
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
    dynamic firstOperand,
    dynamic secondOperand,
    String? comparisonOperator,
    NodeModel? output,
    List<ConnectionPointModel>? connectionPoints,
  }) {
    return SimpleConditionNode(
      position: position ?? this.position,
    )
      ..firstOperand = firstOperand ?? this.firstOperand
      ..secondOperand = secondOperand ?? this.secondOperand
      ..comparisonOperator = comparisonOperator ?? this.comparisonOperator
      ..isConnected = isConnected ?? this.isConnected
      ..child = null
      ..parent = null
      ..output = null
      ..connectionPoints = connectionPoints ??
          List<ConnectionPointModel>.from(
              this.connectionPoints.map((cp) => cp.copy()));
  }

  @override
  SimpleConditionNode copy() {
    return copyWith() as SimpleConditionNode;
  }

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'SimpleConditionNode';
    map['firstOperand'] = firstOperand;
    map['secondOperand'] = secondOperand;
    map['comparisonOperator'] = comparisonOperator;
    return map;
  }

  static SimpleConditionNode fromJson(Map<String, dynamic> json) {
    return SimpleConditionNode(
      position: OffsetJson.fromJson(json['position']),
      firstOperand: json['firstOperand'],
      secondOperand: json['secondOperand'],
      comparisonOperator: json['comparisonOperator'],
    )
      ..id = json['id']
      ..isConnected = json['isConnected'] ?? false
      ..connectionPoints = (json['connectionPoints'] as List)
          .map((e) => ConnectionPointModel.fromJson(e))
          .toList();
  }
}
