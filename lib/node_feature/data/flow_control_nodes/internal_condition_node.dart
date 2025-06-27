import 'package:flutter/material.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/logic_element.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/flow_control_node_widgets/internal_node_widget.dart';

class InternalConditionNode extends LogicElementNode with HasOutput {
  final dynamic firstOperand;
  final dynamic secondOperand;
  final String comparisonOperator;

  InternalConditionNode({
    required this.firstOperand,
    required this.comparisonOperator,
    required this.secondOperand,
    required super.color,
    required super.width,
    required super.height,
  }) : super(connectionPoints: []);

  static InternalConditionNode fromJson(Map<String, dynamic> json) {
    return InternalConditionNode(
      firstOperand: json['firstOperand'],
      secondOperand: json['secondOperand'],
      comparisonOperator: json['comparisonOperator'],
      color: Color(json['color']),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    )..id = json['id'];
  }

  @override
  Result<bool> execute([Entity? entity]) {
    if (firstOperand == null || secondOperand == null || comparisonOperator.isEmpty) {
      return Result.failure(errorMessage: "Missing operand or operator.");
    }

    dynamic op1 = firstOperand;
    dynamic op2 = secondOperand;

    if (entity != null) {
      if (entity.variables.containsKey(op1)) {
        op1 = entity.variables[op1];
      }
      if (entity.variables.containsKey(op2)) {
        op2 = entity.variables[op2];
      }
    }

    final num1 = _tryParseDouble(op1);
    final num2 = _tryParseDouble(op2);

    switch (comparisonOperator) {
      case '==':
        return Result.success(result: op1 == op2 || num1 == num2);
      case '!=':
        return Result.success(result: op1 != op2 && num1 != num2);
      case '>':
        if (num1 != null && num2 != null) {
          return Result.success(result: num1 > num2);
        }
        break;
      case '<':
        if (num1 != null && num2 != null) {
          return Result.success(result: num1 < num2);
        }
        break;
      case '>=':
        if (num1 != null && num2 != null) {
          return Result.success(result: num1 >= num2);
        }
        break;
      case '<=':
        if (num1 != null && num2 != null) {
          return Result.success(result: num1 <= num2);
        }
        break;
    }

    return Result.failure(errorMessage: "Invalid comparison or incompatible types.");
  }

  double? _tryParseDouble(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }

  @override
  String toString() => "$firstOperand $comparisonOperator $secondOperand";

  @override
  Widget buildNode() {
    return InternalConditionNodeWidget(node: this);
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
    dynamic firstOperand,
    dynamic secondOperand,
    String? comparisonOperator,
    List<ConnectionPointModel>? connectionPoints,
  }) {
    return InternalConditionNode(
      firstOperand: firstOperand ?? this.firstOperand,
      comparisonOperator: comparisonOperator ?? this.comparisonOperator,
      secondOperand: secondOperand ?? this.secondOperand,
      color: color ?? this.color,
      width: width ?? this.width,
      height: height ?? this.height,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = child ?? this.child?.copy()
      ..parent = parent ?? this.parent?.copy()
      ..output = output ?? this.output?.copy()
      ..connectionPoints = connectionPoints ?? List<ConnectionPointModel>.from(this.connectionPoints.map((cp) => cp.copy()));
  }

  @override
  NodeModel copy() {
    return copyWith(
      position: position,
      color: color,
      width: width,
      height: height,
      isConnected: isConnected,
      child: child?.copy(),
      parent: parent?.copy(),
      output: output?.copy(),
      firstOperand: firstOperand,
      secondOperand: secondOperand,
      comparisonOperator: comparisonOperator,
    ) as InternalConditionNode;
  }
}