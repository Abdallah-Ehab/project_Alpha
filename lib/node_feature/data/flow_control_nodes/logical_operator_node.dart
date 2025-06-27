import 'package:flutter/material.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/logic_element.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';

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
  NodeModel copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    LogicalOperator? operator,
    List<ConnectionPointModel>? connectionPoints,
  }) {
    return LogicOperatorNode(
      operator: operator ?? this.operator,
      color: color ?? this.color,
      width: width ?? this.width,
      height: height ?? this.height,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = child ?? this.child?.copy()
      ..parent = parent ?? this.parent?.copy()
      ..connectionPoints = connectionPoints ??
          List<ConnectionPointModel>.from(
              this.connectionPoints.map((cp) => cp.copy()));
  }

  static LogicOperatorNode fromJson(Map<String, dynamic> json) {
    return LogicOperatorNode(
      operator: LogicalOperator.values
          .firstWhere((e) => e.toString() == json['operator']),
      color: Color(json['color']),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    )..id = json['id'];
  }

  @override
  LogicOperatorNode copy() {
    return copyWith(
      position: position,
      color: color,
      width: width,
      height: height,
      isConnected: isConnected,
      child: child?.copy(),
      parent: parent?.copy(),
      operator: operator,
    ) as LogicOperatorNode;
  }
}
