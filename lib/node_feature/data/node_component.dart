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
import 'package:scratch_clone/node_feature/data/variable_related_nodes/declare_variable_node.dart';



class NodeComponent extends Component {
  NodeModel? startNode;
  NodeModel? current;
  late List<NodeModel> workspaceNodes;

  NodeComponent({
    super.isActive = true,
    NodeModel? startNode,
    this.current,
    List<NodeModel>? workspaceNodes
  }){
    this.startNode = StartNode();
    this.workspaceNodes = workspaceNodes ?? [this.startNode! , IfNode(), ConditionGroupNode(logicSequence: []),StatementGroupNode(statements: []),MoveNode(),DeclareVariableNode()];
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

  @override
  void update(Duration dt, {required Entity activeEntity}) {

    current = startNode;

    while (current != null) {
      log('${current?.child} is child of $current of id : ${current?.id}');
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
      workspaceNodes: workspaceNodes.map((node) => node.copy()).toList(),
      current: current?.copy(),
    );
  }
}
