import 'package:flutter/material.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/logic_element.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';

enum LogicalOperator { and, or }

extension LogicalOperatorSymbol on LogicalOperator {
  String get symbol {
    switch (this) {
      case LogicalOperator.and:
        return "&&";
      case LogicalOperator.or:
        return "||";
    }
  }
}


class LogicOperatorNode extends LogicElementNode {
  final LogicalOperator operator;

  LogicOperatorNode({
    required this.operator,
    required super.color,
    required super.width,
    required super.height,
    
  }) : super(connectionPoints: []);

  @override
  Result<bool> execute([Entity? entity]) {
    throw UnimplementedError("OperatorNode does not execute alone.");
  }

  @override
  Widget buildNode() {
    return Container(
      width: width,
      height: height,
      color: color,
      child: Center(
        child: Text(
          operator.symbol,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
    );
  }

  @override
  LogicOperatorNode copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    bool? isDragTarget,
    List<ConnectionPointModel>? connectionPoints,
    LogicalOperator? operator,
  }) {
    return LogicOperatorNode(
      operator: operator ?? this.operator,
      color: color ?? this.color,
      width: width ?? this.width,
      height: height ?? this.height,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = child ?? this.child
      ..parent = parent ?? this.parent;
  }
  
  @override
LogicOperatorNode copy() {
  return LogicOperatorNode(
    operator: operator,
    color: color,
    width: width,
    height: height,
  )
    ..isConnected = isConnected
    ..child = child
    ..parent = parent;
}
}

