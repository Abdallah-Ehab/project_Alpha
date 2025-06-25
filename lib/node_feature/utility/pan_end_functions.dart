import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_component.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/domain/connection_provider.dart';

// void handleConnectPanEnd(BuildContext context, NodeModel fromNode) {
//   log("handleConnectPanEnd called");

//   final entityManager = Provider.of<EntityManager>(context, listen: false);
//   final activeEntity = entityManager.activeEntity;
//   final nodeComponent = activeEntity.getComponent<NodeComponent>();

//   if (nodeComponent == null) {
//     log("No NodeComponent found");
//     return;
//   }

//   final provider = Provider.of<ConnectionProvider>(context, listen: false);
//   final endPos = provider.currentPosition;
//   final nodes = nodeComponent.workspaceNodes;

//   for (var targetNode in nodes) {
//     if (targetNode.id == fromNode.id) continue;

//     for (var point in targetNode.connectionPoints) {
//       if (point is! ConnectConnectionPoint) continue;

//       final pointPos = targetNode.position + point.computeOffset(targetNode);
//       if ((endPos! - pointPos).distance <= 20) {
//         bool isTopTarget = point.isTop;

//         if (isTopFrom == isTopTarget) continue;

//         NodeModel parent, child;

//         if (!isTopFrom && isTopTarget) {
//           parent = fromNode;
//           child = targetNode;
//         } else {
//           parent = targetNode;
//           child = fromNode;
//         }

//         parent.connectNode(child);
//         provider.clear();
//         return;
//       }
//     }
//   }

//   provider.clear();
// }



// void handleOutputPanEnd(BuildContext context, NodeModel owner) {
//   final entityManager = Provider.of<EntityManager>(context, listen: false);
//   final activeEntity = entityManager.activeEntity;
//   final nodeComponent = activeEntity.getComponent<NodeComponent>();

//   if (nodeComponent == null) {
//     log("No NodeComponent found");
//     return;
//   }

//   final provider = Provider.of<ConnectionProvider>(context, listen: false);
//   final endPos = provider.currentPosition;
//   final nodes = nodeComponent.workspaceNodes;

//   for (var targetNode in nodes) {
//     if (targetNode.id == owner.id) continue;

//     for (var point in targetNode.connectionPoints) {
//       if (point is! InputConnectionPoint) continue;

//       final pointPos = targetNode.position + point.computeOffset(targetNode);
//       if ((endPos! - pointPos).distance <= 20) {
//         if (owner is HasOutput && targetNode is HasInput) {
//           owner.connectOutput(targetNode);
//           provider.clear();
//           return;
//         }
//       }
//     }
//   }

//   provider.clear();
// }
