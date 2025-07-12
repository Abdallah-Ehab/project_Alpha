import 'package:flutter/cupertino.dart';
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
        // Optional: logging or effects
      },
      onPanUpdate: (details) {
        final entityManager = Provider.of<EntityManager>(context, listen: false);
        final activeEntity = entityManager.activeEntity;
        final nodeComponent = activeEntity?.getComponent<NodeComponent>();

        if (nodeComponent == null) return;

        // Check if it's inside any statement group
        for (var node in nodeComponent.workspaceNodes) {
          if (node is! StatementGroupNode) continue;

          if (nodeModel.isStatement && !nodeComponent.workspaceNodes.any((node) => node.id == nodeModel.id)) {
            // If already inside a group and being dragged out
            node.removeStatement(nodeModel);
            nodeComponent.addNodeToWorkspace(nodeModel);
            nodeModel.isStatement = false;
            return;
          }

          final groupRect = Rect.fromLTWH(
            node.position.dx,
            node.position.dy,
            node.width,
            node.height,
          );

          final draggedRect = Rect.fromLTWH(
            nodeModel.position.dx,
            nodeModel.position.dy,
            nodeModel.width,
            nodeModel.height,
          );

          if (groupRect.overlaps(draggedRect.inflate(20)) &&
              nodeModel is! StatementGroupNode) {
            node.highlightNode(true);
            break;
          }else{
            node.highlightNode(false);
          }
        }

        // Move the node visually
        nodeModel.updatePosition(details.globalPosition);
      },
      onPanEnd: (details) {
        final entityManager = Provider.of<EntityManager>(context, listen: false);
        final activeEntity = entityManager.activeEntity;
        final nodeComponent = activeEntity?.getComponent<NodeComponent>();

        if (nodeComponent == null) return;

        for (var node in nodeComponent.workspaceNodes) {
          if (node is! StatementGroupNode) continue;

          final groupRect = Rect.fromLTWH(
            node.position.dx,
            node.position.dy,
            node.width,
            node.height,
          );

          final draggedRect = Rect.fromLTWH(
            nodeModel.position.dx,
            nodeModel.position.dy,
            nodeModel.width,
            nodeModel.height,
          );

          if (groupRect.overlaps(draggedRect.inflate(20)) &&
              nodeModel is! StatementGroupNode) {
            final alreadyExists = node.statements.any((s) => s.id == nodeModel.id);
            if (!alreadyExists && !nodeModel.isStatement) {
              node.addStatement(nodeModel);
              nodeModel.isStatement = true;
              node.highlightNode(false);
              nodeComponent.removeNodeFromWorkspace(nodeModel);
            }
            break;
          }
        }
      },
      child: nodeModel.buildNode(),
    );
  }
}
