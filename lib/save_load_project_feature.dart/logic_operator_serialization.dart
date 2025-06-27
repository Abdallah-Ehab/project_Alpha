import 'dart:ui';

import 'package:scratch_clone/node_feature/data/flow_control_nodes/logic_element.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/logical_operator_node.dart';

extension LogicOperatorNodeSerialization on LogicOperatorNode {
  Map<String, dynamic> toJson() => baseToJson()
    ..addAll({
      'type': 'LogicOperatorNode',
      'operator': operator.toString(),
    });

  static LogicOperatorNode fromJson(Map<String, dynamic> json) {
    return LogicOperatorNode(
      operator: LogicalOperator.values.firstWhere(
          (e) => e.toString() == json['operator']),
      color: Color(json['color']),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    )..id = json['id'];
  }
  }