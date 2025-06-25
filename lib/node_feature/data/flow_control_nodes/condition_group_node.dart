import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/logic_element.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/logical_operator_node.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/flow_control/condition_group_node_widget.dart';

class ConditionGroupNode extends NodeModel {
  final List<LogicElementNode> logicSequence;

  final double baseHeight = 120;
  final double extraHeightPerTwoItems = 40;

  ConditionGroupNode({
    required this.logicSequence,
    required super.color,
    required super.width,
    required super.height,
  }) : super(connectionPoints: [
          OutputConnectionPoint(position: Offset.zero, width: 50)
        ]);

  void addLogicNode(LogicElementNode node) {
    logicSequence.add(node);
    _resize();
    notifyListeners();
  }

  void removeLogicNode(LogicElementNode node) {
    logicSequence.remove(node);
    _resize();
    notifyListeners();
  }

  void _resize() {
    // Expand every 2 additional nodes beyond 2
    final int extra =
        (logicSequence.length > 2) ? (logicSequence.length - 2) ~/ 2 : 0;
    setHeight(baseHeight + (extra * extraHeightPerTwoItems));
  }

  @override
  void setHeight(double height) {
    this.height = height;
    notifyListeners();
  }

  @override
  void setWidth(double width) {
    this.width = width;
    notifyListeners();
  }

  @override
  Result<bool> execute([Entity? activeEntity]) {
    if (!isValidSequence()) {
      return Result.failure(
          errorMessage:
              "Invalid condition sequence (missing or misplaced logical operator).");
    }

    bool? result;
    LogicalOperator? pendingOperator;

    for (var node in logicSequence) {
      if (node is LogicOperatorNode) {
        pendingOperator = node.operator;
      } else {
        final conditionResult = node.execute(activeEntity);
        if (conditionResult.errorMessage != null) {
          return Result.failure(errorMessage: conditionResult.errorMessage);
        }
        final bool value = conditionResult.result ?? false;

        if (result == null) {
          result = value;
        } else {
          switch (pendingOperator) {
            case LogicalOperator.and:
              result = result && value;
              break;
            case LogicalOperator.or:
              result = result || value;
              break;
            default:
              return Result.failure(
                  errorMessage: "Missing logical operator between conditions.");
          }
        }
        pendingOperator = null;
      }
    }

    return Result.success(result: result ?? false);
  }

  bool isValidSequence() {
    if (logicSequence.isEmpty) return false;
    if (logicSequence.first is LogicOperatorNode) return false;
    if (logicSequence.last is LogicOperatorNode) return false;

    for (int i = 0; i < logicSequence.length - 1; i++) {
      bool currentIsOp = logicSequence[i] is LogicOperatorNode;
      bool nextIsOp = logicSequence[i + 1] is LogicOperatorNode;
      if (currentIsOp && nextIsOp) return false;
    }

    return true;
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: ConditionGroupNodeWidget(node: this),
    );
  }

  @override
  ConditionGroupNode copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    List<LogicElementNode>? logicSequence,
    List<ConnectionPointModel>? connectionPoints,
  }) {
    return ConditionGroupNode(
      logicSequence: logicSequence ?? this.logicSequence,
      color: color ?? this.color,
      width: width ?? this.width,
      height: height ?? this.height,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = child ?? this.child
      ..parent = parent ?? this.parent;
  }

  @override
  ConditionGroupNode copy() {
    return ConditionGroupNode(
      logicSequence:
          logicSequence.map((e) => e.copy() as LogicElementNode).toList(),
      color: color,
      width: width,
      height: height,
    )
      ..isConnected = isConnected
      ..child = child
      ..parent = parent;
  }
}
