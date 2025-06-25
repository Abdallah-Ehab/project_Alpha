import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:scratch_clone/component/component.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/if_node.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';

class NodeComponent extends Component {
  NodeModel? startNode;
  NodeModel? current;
  Duration lastUpdate;
  final List<NodeModel> workspaceNodes;

  NodeComponent({
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
              IfNode(
                position: const Offset(100, 250),
                color: Colors.green,
                width: 150,
                height: 75,
              ),
            ];

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
    current = startNode;

    while (current != null) {
      final result = current!.execute(activeEntity);
      if (result.errorMessage != null) {
        log("Execution error: ${result.errorMessage}");
        break;
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
  Map<String, dynamic> toJson() {
    // Optional: implement if needed for serialization
    return {
      'nodes': workspaceNodes.map((node) => node.id).toList(),
      'startNode': startNode?.id,
    };
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
