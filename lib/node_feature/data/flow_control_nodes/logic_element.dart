import 'dart:ui';

import 'package:scratch_clone/node_feature/data/flow_control_nodes/internal_condition_node.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/logical_operator_node.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';

abstract class LogicElementNode extends NodeModel {
  LogicElementNode({
    super.position = Offset.zero,
    required super.color,
    required super.width,
    required super.height,
    required super.connectionPoints,
  });

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'LogicElementNode'; // fallback for unknown or base usage
    return map;
  }

  static LogicElementNode fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    switch (type) {
      case 'InternalConditionNode':
        return InternalConditionNode.fromJson(json);
      case 'LogicOperatorNode':
        return LogicOperatorNode.fromJson(json);
      // Add more subclasses here as needed
      default:
        throw UnimplementedError('Unknown LogicElementNode type: $type');
    }
  }
}


enum LogicalOperator { and, or }
