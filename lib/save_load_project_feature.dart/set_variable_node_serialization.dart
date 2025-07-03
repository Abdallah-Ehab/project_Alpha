
import 'package:scratch_clone/node_feature/data/variable_related_nodes/declare_variable_node.dart';
import 'package:scratch_clone/node_feature/data/variable_related_nodes/set_variable_node.dart';

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
      );
}


extension DeclareVariableNodeSerialization on DeclareVariableNode {
  Map<String, dynamic> toJson() => baseToJson()
    ..addAll({
      'type': 'SetVariableNode',
      'variableName': variableName,
      'value': value,
    });

  static DeclareVariableNode fromJson(Map<String, dynamic> json) => DeclareVariableNode(
        variableName: json['variableName'] as String,
        value: json['value'],
      );
}