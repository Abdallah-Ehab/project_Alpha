import 'dart:ui';

import 'package:scratch_clone/node_feature/data/flow_control_nodes/condition_group_node.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/logic_element.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';

extension ConditionGroupNodeSerialization on ConditionGroupNode {
  Map<String, dynamic> toJson() => baseToJson()
    ..addAll({
      'type': 'ConditionGroupNode',
      'logicSequence': logicSequence.map((e) => e.baseToJson()).toList(),
    });

  static ConditionGroupNode fromJson(Map<String, dynamic> json) {
    final logicNodes = (json['logicSequence'] as List<dynamic>)
        .map((e) => NodeModel.fromJson(e) as LogicElementNode)
        .toList();

    return ConditionGroupNode(
      logicSequence: logicNodes,
    )..id = json['id'];
  }
}