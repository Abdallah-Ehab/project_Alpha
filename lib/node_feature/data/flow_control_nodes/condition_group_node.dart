import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/logic_element.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/logical_operator_node.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/flow_control_node_widgets/condition_group_node_widget.dart';

class ConditionGroupNode extends InputNode {
  final List<LogicElementNode> logicSequence;

  final double baseHeight = 120;
  final double extraHeightPerTwoItems = 40;

  ConditionGroupNode({
    required this.logicSequence,
    super.position = Offset.zero
  }) : super(
          image: 'assets/icons/condition',
          connectionPoints: [
            OutputConnectionPoint(position: Offset.zero, width: 50),
          ],
          width: 300, height: 300,color: Colors.redAccent
        );

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
    final int extra = (logicSequence.length > 2) ? (logicSequence.length - 2) ~/ 2 : 0;
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
          errorMessage: "Invalid condition sequence (missing or misplaced logical operator).");

     
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
  NodeModel copyWith({
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
      position: position ?? this.position,
      logicSequence: logicSequence ?? List<LogicElementNode>.from(this.logicSequence.map((e) => e.copy() as LogicElementNode)),
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = null
      ..parent = null
      ..connectionPoints = connectionPoints ?? List<ConnectionPointModel>.from(this.connectionPoints.map((cp) => cp.copy()));
  }

  @override
  ConditionGroupNode copy() {
    final conditionGroupCopy = copyWith() as ConditionGroupNode;
    return conditionGroupCopy;
  }

  @override
Map<String, dynamic> baseToJson() {
  final map = super.baseToJson();
  map['type'] = 'ConditionGroupNode';
  map['logicSequence'] = logicSequence.map((node) => node.baseToJson()).toList();
  return map;
}

static ConditionGroupNode fromJson(Map<String, dynamic> json) {
  final positionJson = json['position'];
  final position = Offset(positionJson['dx'], positionJson['dy']);

  final logicSequenceJson = json['logicSequence'] as List;
  final logicSequence = logicSequenceJson
      .map((e) => LogicElementNode.fromJson(e)) // You'll need a factory here
      .toList();

  final connectionPointsJson = json['connectionPoints'] as List;
  final connectionPoints = connectionPointsJson
      .map((e) => ConnectionPointModel.fromJson(e))
      .toList();

  final node = ConditionGroupNode(
    logicSequence: logicSequence,
    position: position,
  )
    ..id = json['id']
    ..width = (json['width'] as num).toDouble()
    ..height = (json['height'] as num).toDouble()
    ..isConnected = json['isConnected'] as bool
    ..connectionPoints = connectionPoints;

  return node;
}

}
