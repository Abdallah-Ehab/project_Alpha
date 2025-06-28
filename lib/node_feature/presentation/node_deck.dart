import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/else_node.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/if_node.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/while_node.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/teleport_node.dart';
import 'package:scratch_clone/node_feature/presentation/node_icon_widget.dart';

class NodeDeck extends StatelessWidget {
  NodeDeck({super.key});
  
  final List<NodeModel> nodeTemplates = [
    StartNode(),
    IfNode(),
    ElseNode(),
    WhileNode(),
    TeleportNode(),
  ];


  @override
  Widget build(BuildContext context) {
    return Column(
      children: nodeTemplates.map((node) {
        return NodeIconWidget(
          nodeModel: node,
          label: node.runtimeType.toString().replaceAll('Node', ''),
        );
      }).toList(),
    );
  }
}