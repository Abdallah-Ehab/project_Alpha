
import 'package:scratch_clone/node_feature/data/node_component.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';

extension NodeComponentSerialization on NodeComponent {
  Map<String, dynamic> toJson() => {
        'type': 'NodeComponent',
        'isActive': isActive,
        'workspaceNodes': workspaceNodes.map((node) => node.baseToJson()).toList(),
        'startNodeId': startNode?.id,
      };

  static NodeComponent fromJson(Map<String, dynamic> json) {
    final workspaceNodesJson = json['workspaceNodes'] as List<dynamic>;
    final nodes = workspaceNodesJson.map((e) => NodeModel.fromJson(e)).toList();

    return NodeComponent(
      isActive: json['isActive'] as bool,
      workspaceNodes: nodes,
    );
  }
}
