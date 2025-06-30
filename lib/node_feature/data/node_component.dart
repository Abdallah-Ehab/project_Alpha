import 'dart:developer';
import 'package:scratch_clone/component/component.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/condition_group_node.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/else_node.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/if_node.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/output_nodes/statement_group_node.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/move_node.dart';
import 'package:scratch_clone/node_feature/data/spawn_node/spawn_node.dart';
import 'package:scratch_clone/node_feature/data/variable_related_nodes/declare_variable_node.dart';

class NodeComponent extends Component {
  NodeModel? startNode;
  late List<NodeModel> workspaceNodes;

  NodeComponent(
      {super.isActive = true,
      NodeModel? startNode,
      List<NodeModel>? workspaceNodes}) {
    this.startNode = startNode ?? StartNode();
    this.workspaceNodes = workspaceNodes ??
        [
          this.startNode!,
          IfNode(),
          ConditionGroupNode(logicSequence: []),
          StatementGroupNode(statements: []),
          MoveNode(),
          DeclareVariableNode(),
          SpawnEntityNode()
        ];
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'NodeComponent',
        'isActive': isActive,
        'workspaceNodes':
            workspaceNodes.map((node) => node.baseToJson()).toList(),
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

  void addNodeToWorkspace(NodeModel node) {
    workspaceNodes.add(node);
    startNode ??= node;
    notifyListeners();
  }

  void removeNodeFromWorkspace(NodeModel node) {
    if (startNode == node) return;
    workspaceNodes.remove(node);
    notifyListeners();
  }

  NodeModel? _current;
  @override
  void update(Duration dt, {required Entity activeEntity}) {
    
    _current = startNode;

    while (_current != null) {
      log('${_current?.child} is child of $_current of id : ${_current?.id}');
      final result = _current!.execute(activeEntity);
      if (result.errorMessage != null) {
        log("Execution error: ${result.errorMessage}");
        break;
      }

      // Special case: IfNode false condition
      if (_current is IfNode &&
          result is Result<bool> &&
          result.result == false) {
        final elseNode = _current!.child;
        if (elseNode is ElseNode) {
          final elseResult = elseNode.execute(activeEntity);
          if (elseResult.errorMessage != null) {
            log("Else block error: ${elseResult.errorMessage}");
            break;
          }
          _current = elseNode.child;
          continue;
        }
      }

      _current = _current!.child;
    }

    notifyListeners();
  }

  @override
  void reset() {
    _current = startNode;
    notifyListeners();
  }

  @override
  NodeComponent copy() {
    // Copy all workspace nodes (this breaks all connections since each gets new UUIDs)
    final copiedNodes = workspaceNodes.map((node) => node.copy()).toList();

    // Restore ALL connections between nodes using index-based matching
    for (int i = 0; i < workspaceNodes.length; i++) {
      final originalNode = workspaceNodes[i];
      final copiedNode = copiedNodes[i];

      // If original node has a child, find its index and connect to copied version
      if (originalNode.child != null) {
        final childIndex = workspaceNodes.indexOf(originalNode.child!);
        if (childIndex != -1) {
          copiedNode.connectNode(copiedNodes[childIndex]);
        }
      }
    }

    // Find the copied startNode
    NodeModel? newStartNode;
    if (startNode != null) {
      final startIndex = workspaceNodes.indexOf(startNode!);
      if (startIndex != -1) {
        newStartNode = copiedNodes[startIndex];
      }
    }

    return NodeComponent(
      isActive: isActive,
      startNode: newStartNode,
      workspaceNodes: copiedNodes,
    );
  }
}
