import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/condition_group_node.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/else_node.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/if_node.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/simple_condition_node.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/while_node.dart';
import 'package:scratch_clone/node_feature/data/math_nodes/add_node.dart';
import 'package:scratch_clone/node_feature/data/math_nodes/div_node.dart';
import 'package:scratch_clone/node_feature/data/math_nodes/mul_node.dart';
import 'package:scratch_clone/node_feature/data/math_nodes/subtract_node.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/object_property_nodes/get_property_node.dart';
import 'package:scratch_clone/node_feature/data/output_nodes/statement_group_node.dart';
import 'package:scratch_clone/node_feature/data/physics_related_nodes/collision_detection_node.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/apply_force_node.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/flip_node.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/move_node.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/teleport_node.dart';
import 'package:scratch_clone/node_feature/data/spawn_node/destroy_entity_node.dart';
import 'package:scratch_clone/node_feature/data/spawn_node/spawn_node.dart';
import 'package:scratch_clone/node_feature/data/spawn_node/spawn_node_at_position.dart';
import 'package:scratch_clone/node_feature/data/time_related_nodes/wait_for_node.dart';
import 'package:scratch_clone/node_feature/data/variable_related_nodes/declare_list_node.dart';
import 'package:scratch_clone/node_feature/data/variable_related_nodes/declare_variable_node.dart';
import 'package:scratch_clone/node_feature/data/variable_related_nodes/set_variable_node.dart';
import 'package:scratch_clone/node_feature/presentation/node_icon_widget.dart';

class NodeDeck extends StatelessWidget {
  NodeDeck({super.key});

  final List<NodeModel> flowControlNodes = [
    IfNode(),
    ElseNode(),
    WhileNode(),
    StatementGroupNode(statements: []),
    ConditionGroupNode(logicSequence: []),
    SimpleConditionNode(),
    DetectCollisionNode(),
    
  ];

  final List<NodeModel> playerTransformNodes = [
    TeleportNode(),
    MoveNode(),
    ApplyForceNode(),
    SimpleFlipNode(),
    WaitForNode()
  ];

  final List<NodeModel> variableNodes = [
    DeclareVariableNode(),
    SetVariableNode(),
    DeclareListNode(),
  ];

  final List<NodeModel> entityNodes = [
    GetPropertyFromEntityNode(),
    SpawnEntityNode(),
    SpawnAtNode(),
    DestroyEntityNode()
  ];

  final List<NodeModel> mathNodes = [
    AddNode(),
    SubtractNode(),
    MultiplyNode(),
    DivideNode(),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildNodeGroup("Flow Control", flowControlNodes),
          buildNodeGroup("Player Transform", playerTransformNodes),
          buildNodeGroup("Variables", variableNodes),
          buildNodeGroup("Entities", entityNodes),
          buildNodeGroup("Math", mathNodes),
        ],
      ),
    );
  }

  Widget buildNodeGroup(String title, List<NodeModel> nodes) {
    final List<List<NodeModel>> rows = [];
    for (int i = 0; i < nodes.length; i += 4) {
      rows.add(nodes.sublist(i, i + 4 > nodes.length ? nodes.length : i + 4));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Node Rows
          Column(
            children: rows.map((row) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: row.map((node) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: NodeIconWidget(
                        nodeModel: node,
                        label: node.runtimeType.toString().replaceAll('Node', ''),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
