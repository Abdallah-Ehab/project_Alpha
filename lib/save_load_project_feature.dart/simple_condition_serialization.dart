import 'dart:ui';

import 'package:scratch_clone/node_feature/data/flow_control_nodes/simple_condition_node.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

extension SimpleConditionNodeSerialization on SimpleConditionNode {
  Map<String, dynamic> toJson() => baseToJson()
    ..addAll({
      'type': 'SimpleConditionNode',
      'firstOperand': firstOperand,
      'secondOperand': secondOperand,
      'comparisonOperator': comparisonOperator,
    });

  static SimpleConditionNode fromJson(Map<String, dynamic> json) => SimpleConditionNode(
        position: OffsetJson.fromJson(json['position']),
       
      )
        ..firstOperand = json['firstOperand']
        ..secondOperand = json['secondOperand']
        ..comparisonOperator = json['comparisonOperator'];
}
