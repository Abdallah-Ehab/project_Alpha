import 'dart:ui';

import 'package:scratch_clone/node_feature/data/flow_control_nodes/internal_condition_node.dart';

extension InternalConditionNodeSerialization on InternalConditionNode {
  Map<String, dynamic> toJson() => baseToJson()
    ..addAll({
      'type': 'InternalConditionNode',
      'firstOperand': firstOperand,
      'secondOperand': secondOperand,
      'comparisonOperator': comparisonOperator,
    });

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
}