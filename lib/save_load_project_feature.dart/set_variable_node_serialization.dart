import 'dart:ui';

import 'package:scratch_clone/node_feature/data/variable_related_nodes/set_variable_node.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

extension SetVariableNodeSerialization on SetVariableNode {
  Map<String, dynamic> toJson() => baseToJson()
    ..addAll({
      'type': 'SetVariableNode',
      'variableName': variableName,
      'value': value,
    });

  static SetVariableNode fromJson(Map<String, dynamic> json) => SetVariableNode(
        variableName: json['variableName'] as String,
        value: json['value'],
        position: OffsetJson.fromJson(json['position']),
        color: Color(json['color']),
        width: (json['width'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
      );
}