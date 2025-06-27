import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/output_nodes/statement_group_node.dart';

extension StatementGroupNodeSerialization on StatementGroupNode {
  Map<String, dynamic> toJson() => baseToJson()
    ..addAll({
      'type': 'StatementGroupNode',
      'isHighlighted': isHighlighted,
      'statements': statements.map((e) => e.baseToJson()).toList(),
    });

  static StatementGroupNode fromJson(Map<String, dynamic> json) => StatementGroupNode(
        isHighlighted: json['isHighlighted'],
        statements: (json['statements'] as List<dynamic>)
            .map((e) => NodeModel.fromJson(e))
            .toList(),
      );
}
