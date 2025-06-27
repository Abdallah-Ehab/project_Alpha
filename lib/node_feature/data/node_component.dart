import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:scratch_clone/component/component.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/condition_group_node.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/else_node.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/if_node.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/output_nodes/statement_group_node.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/move_node.dart';

class NodeComponent extends Component {
  NodeModel? startNode;
  NodeModel? current;
  Duration lastUpdate;
  final List<NodeModel> workspaceNodes;

  NodeComponent({
    super.isActive = true,
    this.startNode,
    this.current,
    this.lastUpdate = Duration.zero,
    List<NodeModel>? workspaceNodes,
  }) : workspaceNodes = workspaceNodes ??
            [
              IfNode(
                position: const Offset(100, 100),
                color: Colors.green,
                width: 150,
                height: 75,
              ),
              ConditionGroupNode(
                logicSequence: [],
                color: Colors.red,
                width: 150,
                height: 75,
              ),
              StatementGroupNode(statements: [],),
              MoveNode()
            ];

  @override
  Map<String, dynamic> toJson() => {
        'type': 'NodeComponent',
        'isActive': isActive,
        'lastUpdate': lastUpdate.inMilliseconds,
        'workspaceNodes':
            workspaceNodes.map((node) => node.baseToJson()).toList(),
        'startNodeId': startNode?.id,
      };

  static NodeComponent fromJson(Map<String, dynamic> json) {
    final workspaceNodesJson = json['workspaceNodes'] as List<dynamic>;
    final nodes = workspaceNodesJson.map((e) => NodeModel.fromJson(e)).toList();
    final idMap = {for (var node in nodes) node.id: node};

    return NodeComponent(
      isActive: json['isActive'] as bool,
      lastUpdate: Duration(milliseconds: json['lastUpdate'] as int),
      workspaceNodes: nodes,
      startNode: idMap[json['startNodeId']],
    );
  }

  void addNodeToWorkspace(NodeModel node) {
    workspaceNodes.add(node);
    startNode ??= node;
    notifyListeners();
  }

  void removeNodeFromWorkspace(NodeModel node) {
    workspaceNodes.remove(node);
    if (startNode == node) startNode = null;
    notifyListeners();
  }

  @override
  void update(Duration dt, {required Entity activeEntity}) {
    if (startNode == null) {
      log("No start node defined in NodeComponent");
      notifyListeners();
      return;
    }

    current = startNode;

    while (current != null) {
      final result = current!.execute(activeEntity);
      if (result.errorMessage != null) {
        log("Execution error: ${result.errorMessage}");
        break;
      }

      // Special case: IfNode false condition
      if (current is IfNode &&
          result is Result<bool> &&
          result.result == false) {
        final elseNode = current!.child;
        if (elseNode is ElseNode) {
          final elseResult = elseNode.execute(activeEntity);
          if (elseResult.errorMessage != null) {
            log("Else block error: ${elseResult.errorMessage}");
            break;
          }
          current = elseNode.child;
          continue;
        }
      }

      current = current!.child;
    }

    notifyListeners();
  }

  @override
  void reset() {
    current = startNode;
    notifyListeners();
  }

  @override
  NodeComponent copy() {
    return NodeComponent(
      lastUpdate: lastUpdate,
      workspaceNodes: workspaceNodes.map((node) => node.copy()).toList(),
      startNode: startNode?.copy(),
      current: current?.copy(),
    );
  }
}
