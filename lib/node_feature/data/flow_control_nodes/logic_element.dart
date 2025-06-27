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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': 'LogicElementNode', // Used as fallback; subclasses override it
      'position': {'dx': position.dx, 'dy': position.dy},
      'color': color.toARGB32(),
      'width': width,
      'height': height,
      'isConnected': isConnected,
      'childId': child?.id,
      'parentId': parent?.id,
      if (this is HasOutput) 'outputId': (this as HasOutput).output?.id,
      if (this is HasInput) 'inputId': (this as HasInput).input?.id,
      if (this is HasValue) 'sourceNodeId': (this as HasValue).sourceNode?.id,
    };
  }

  static LogicElementNode fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    switch (type) {
      case 'InternalConditionNode':
        return InternalConditionNode.fromJson(json);
      case 'LogicOperatorNode':
        return LogicOperatorNode.fromJson(json);
      // Add more subclasses here
      default:
        throw UnimplementedError('Unknown LogicElementNode type: $type');
    }
  }
}


enum LogicalOperator { and, or }
