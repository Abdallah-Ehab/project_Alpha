import 'dart:core';

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
import 'package:scratch_clone/node_feature/data/variable_related_nodes/declare_list_node.dart';
import 'package:scratch_clone/node_feature/data/variable_related_nodes/declare_variable_node.dart';
import 'package:scratch_clone/node_feature/data/variable_related_nodes/set_variable_node.dart';
import 'package:scratch_clone/node_feature/presentation/node_icon_widget.dart';

class NodeDeck extends StatefulWidget {
  const NodeDeck({super.key});

  @override
  State<NodeDeck> createState() => _NodeDeckState();
}

class _NodeDeckState extends State<NodeDeck> with TickerProviderStateMixin {
  bool isFlowControlExpanded = false;
  bool isPlayerTransformExpanded = false;
  bool isVariableExpanded = false;
  bool isEntityExpanded = false;
  bool isMathExpanded = false;

  final Map<NodeModel, String> flowControlNodes = {
    IfNode(): "IF NODE",
    ElseNode(): "ELSE NODE",
    WhileNode(): "WHILE NODE",
    StatementGroupNode(statements: []): "STATEMENT GROUP",
    ConditionGroupNode(logicSequence: []): "CONDITION GROUP",
    SimpleConditionNode(): "SIMPLE CONDITION",
    DetectCollisionNode(): "DETECT COLLISION",
  };

  final Map<NodeModel, String> playerTransformNodes = {
    TeleportNode(): "TELEPORT NODE",
    MoveNode(): "MOVE NODE",
    ApplyForceNode(): "APPLY FORCE NODE",
    SimpleFlipNode(): "FLIP NODE",
  };

  final Map<NodeModel, String> variableNodes = {
    DeclareVariableNode(): "DECLARE VARIABLE",
    SetVariableNode(): "SET VARIABLE",
    DeclareListNode(): "DECLARE LIST",
  };

  final Map<NodeModel, String> entityNodes = {
    GetPropertyFromEntityNode(): "GET PROPERTY FROM ENTITY",
    SpawnEntityNode(): "SPAWN ENTITY",
    SpawnAtNode(): "SPAWN AT LOCATION",
    DestroyEntityNode(): "DESTROY ENTITY",
  };

  final Map<NodeModel, String> mathNodes = {
    AddNode(): "ADD NODE",
    SubtractNode(): "SUBTRACT NODE",
    MultiplyNode(): "MULTIPLY NODE",
    DivideNode(): "DIVIDE NODE",
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildCategory(
              title: "Flow Control",
              entries: flowControlNodes.entries.toList(),
              isExpanded: isFlowControlExpanded,
              onToggle: () => setState(() {
                isFlowControlExpanded = !isFlowControlExpanded;
              }),
            ),
            buildCategory(
              title: "Player Transform",
              entries: playerTransformNodes.entries.toList(),
              isExpanded: isPlayerTransformExpanded,
              onToggle: () => setState(() {
                isPlayerTransformExpanded = !isPlayerTransformExpanded;
              }),
            ),
            buildCategory(
              title: "Variables",
              entries: variableNodes.entries.toList(),
              isExpanded: isVariableExpanded,
              onToggle: () => setState(() {
                isVariableExpanded = !isVariableExpanded;
              }),
            ),
            buildCategory(
              title: "Entities",
              entries: entityNodes.entries.toList(),
              isExpanded: isEntityExpanded,
              onToggle: () => setState(() {
                isEntityExpanded = !isEntityExpanded;
              }),
            ),
            buildCategory(
              title: "Math",
              entries: mathNodes.entries.toList(),
              isExpanded: isMathExpanded,
              onToggle: () => setState(() {
                isMathExpanded = !isMathExpanded;
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategory({
    required String title,
    required List<MapEntry<NodeModel, String>> entries,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xff555555),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: onToggle,
                icon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Visibility(
              visible: isExpanded,
              maintainState: true,
              maintainAnimation: true,
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    leading: NodeIconWidget(
                      nodeModel: entry.key,
                      label: entry.value,
                    ),
                    title: Text(
                      entry.value,
                      style: const TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

  // Widget buildNodeGroup(String title, List<NodeModel> nodes) {
  //   final List<List<NodeModel>> rows = [];
  //   for (int i = 0; i < nodes.length; i += 4) {
  //     rows.add(nodes.sublist(i, i + 4 > nodes.length ? nodes.length : i + 4));
  //   }

  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 12.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // Group Title
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //           child: Text(
  //             title,
  //             style: const TextStyle(
  //               fontFamily: 'PressStart2P',
  //               fontSize: 12,
  //               color: Colors.white,
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 6),
  //         // Node Rows
  //         Column(
  //           children: rows.map((row) {
  //             return Padding(
  //               padding: const EdgeInsets.symmetric(vertical: 4.0),
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 children: row.map((node) {
  //                   return Padding(
  //                     padding: const EdgeInsets.symmetric(horizontal: 4.0),
  //                     child: NodeIconWidget(
  //                       nodeModel: node,
  //                       label:
  //                           node.runtimeType.toString().replaceAll('Node', ''),
  //                     ),
  //                   );
  //                 }).toList(),
  //               ),
  //             );
  //           }).toList(),
  //         ),
  //       ],
  //     ),
  //   );
  // }

