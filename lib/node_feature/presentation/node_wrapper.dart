

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/data/node_component.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/output_nodes/statement_group_node.dart';

class NodeWrapper extends StatelessWidget {
  final NodeModel nodeModel;

  const NodeWrapper({super.key, required this.nodeModel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        log('node panning started');
      },
      onPanUpdate: (details) {
        nodeModel.updatePosition(details.globalPosition);
      },
      onPanEnd: (details) {
  final entityManager = Provider.of<EntityManager>(context, listen: false);
  final activeEntity = entityManager.activeEntity;
  final nodeComponent = activeEntity.getComponent<NodeComponent>();

  if (nodeComponent == null) return;

  // Check proximity to all StatementGroupNodes
  for (var node in nodeComponent.workspaceNodes) {
    if (node is! StatementGroupNode) continue;

    final groupRect = Rect.fromLTWH(
      node.position.dx,
      node.position.dy,
      node.width,
      node.height,
    );

    final draggedNodeRect = Rect.fromLTWH(
      nodeModel.position.dx,
      nodeModel.position.dy,
      nodeModel.width,
      nodeModel.height,
    );

    if (groupRect.overlaps(draggedNodeRect.inflate(20))) {
      // Add to group
      node.addStatement(nodeModel);

      // Remove from workspace
      nodeComponent.removeNodeFromWorkspace(node);

     
      
      break;
    }
  }
},
      child: nodeModel.buildNode());
  }
}
