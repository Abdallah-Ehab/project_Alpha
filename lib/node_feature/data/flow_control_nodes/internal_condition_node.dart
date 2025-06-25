import 'package:flutter/material.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/logic_element.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/flow_control/internal_node_widget.dart';

class InternalConditionNode extends LogicElementNode with HasOutput {
  final dynamic firstOperand;
  final dynamic secondOperand;
  final String comparisonOperator;

  InternalConditionNode({
    required this.firstOperand,
    required this.comparisonOperator,
    required this.secondOperand, required super.color, required super.width, required super.height,
  }) : super(connectionPoints: []);

  @override
  Result<bool> execute([Entity? entity]) {
    if (firstOperand == null || secondOperand == null || comparisonOperator.isEmpty) {
      return Result.failure(errorMessage: "Missing operand or operator.");
    }

    dynamic op1 = firstOperand;
    dynamic op2 = secondOperand;

    // Try to resolve from variables if entity provided
    if (entity != null) {
      if (entity.variables.containsKey(op1)) {
        op1 = entity.variables[op1];
      }
      if (entity.variables.containsKey(op2)) {
        op2 = entity.variables[op2];
      }
    }

    // Attempt to parse numeric values if they are strings
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
    return InternalConditionNodeWidget(node: this,);
  }

  @override
  NodeModel copyWith({Offset? position, Color? color, double? width, double? height, bool? isConnected, NodeModel? child, NodeModel? parent}) {
    throw UnimplementedError();
  }
  
  @override
  NodeModel copy() {
    // TODO: implement copy
    throw UnimplementedError();
  }
}
