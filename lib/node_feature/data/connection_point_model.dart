import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/data/node_component.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/domain/connection_provider.dart';
import 'package:scratch_clone/node_feature/presentation/connection_point_widget.dart';
import 'package:uuid/uuid.dart';

// each connection point type will have its own onPanEnd, color and position
// the input will have no panning and it will always be on the left
// the output will have panning but it won't be accepted except via an input and it will be always on the right
// the normal connection will be on top and bottom and it will only be accepted by another connection point
// for now lets depend on acyclic relations meaning the node can't connect to itself
// acyclic here is used loosy goosy cause a node can't connect to itself but it can be an intermediate node between a node that is connected to itself
// so in short a node can't connect to itself directly
abstract class ConnectionPointModel {
  final String id;
  final Offset position;
  final Color color;
  final double width;

  ConnectionPointModel(
      {required this.position, required this.color, required this.width})
      : id = const Uuid().v4();

  Widget build(BuildContext context, NodeModel owner);

  Offset computeOffset(NodeModel owner);

  void handlePanEndBehaviour(BuildContext context, NodeModel fromNode);

  void disconnect(NodeModel owner);
}

class InputConnectionPoint extends ConnectionPointModel {
  InputConnectionPoint({required super.position, required super.width})
      : super(color: Colors.redAccent);

  @override
  Widget build(BuildContext context, NodeModel owner) {
    return Positioned(
      top: computeOffset(owner).dy,
      left: computeOffset(owner).dx,
      child: ConnectionPointWidget(
        connectionPoint: this,
        node:
            owner, // yeah yeah I know I just want to be explicit fuck flutter anyway
      ),
    );
  }

  @override
  Offset computeOffset(NodeModel owner) {
    return Offset(-width / 2, owner.height / 2 - width / 2);
  }

  @override
  void handlePanEndBehaviour(BuildContext context, NodeModel fromNode) {
    return;
  }
  
  @override
  void disconnect(NodeModel owner) {
    if(owner is HasOutput){
      owner.disconnectOutput();
    }
  }
}

class OutputConnectionPoint extends ConnectionPointModel {
  OutputConnectionPoint({required super.position, required super.width})
      : super(color: Colors.greenAccent);

  @override
  Widget build(BuildContext context, NodeModel owner) {
    return Positioned(
      left: computeOffset(owner).dx,
      top: computeOffset(owner).dy,
      child: ConnectionPointWidget(connectionPoint: this, node: owner),
    );
  }

  @override
  Offset computeOffset(NodeModel owner) {
    return Offset(owner.width - width / 2, owner.height / 2 - width / 2);
  }

  @override
  void disconnect(NodeModel owner) {
    if(owner is HasInput){
      owner.disconnectInput();
    }
  }

  @override
  void handlePanEndBehaviour(BuildContext context, NodeModel fromNode) {
    final entityManager = Provider.of<EntityManager>(context, listen: false);
    final activeEntity = entityManager.activeEntity;
    final nodeComponent = activeEntity.getComponent<NodeComponent>();

    if (nodeComponent == null) {
      log("No NodeComponent found");
      return;
    }

    final provider = Provider.of<ConnectionProvider>(context, listen: false);
    final endPos = provider.currentPosition;
    final nodes = nodeComponent.workspaceNodes;

    for (var targetNode in nodes) {
      if (targetNode.id == fromNode.id) continue;

      for (var point in targetNode.connectionPoints) {
        if (point is! InputConnectionPoint) continue;

        final pointPos = targetNode.position + point.computeOffset(targetNode);
        if(endPos == null) return;
        if ((endPos - pointPos).distance <= 20) {
          if (fromNode is HasOutput && targetNode is HasInput) {
            fromNode.connectOutput(targetNode);
            log('output node $fromNode is connected to input node $targetNode');
            provider.clear();
            return;
          }
        }
      }
    }

    provider.clear();
  }
}

class ConnectConnectionPoint extends ConnectionPointModel {
  final bool isTop;

  ConnectConnectionPoint(
      {required super.position, required this.isTop, required super.width})
      : super(color: Colors.grey);

  @override
  Widget build(BuildContext context, NodeModel owner) {
    return Positioned(
      left: computeOffset(owner).dx,
      top: computeOffset(owner).dy,
      child: ConnectionPointWidget(
        connectionPoint: this,
        node: owner,
      ),
    );
  }

  @override
  Offset computeOffset(NodeModel owner) {
    return isTop
        ? Offset(owner.width / 2 - width / 2, -width / 2)
        : Offset(owner.width / 2 - width / 2, owner.height - width / 2);
  }

  @override
  void handlePanEndBehaviour(BuildContext context, NodeModel fromNode) {
    log("handleConnectPanEnd called");

    final entityManager = Provider.of<EntityManager>(context, listen: false);
    final activeEntity = entityManager.activeEntity;
    final nodeComponent = activeEntity.getComponent<NodeComponent>();

    if (nodeComponent == null) {
      log("No NodeComponent found");
      return;
    }

    final provider = Provider.of<ConnectionProvider>(context, listen: false);
    final endPos = provider.currentPosition;
    final nodes = nodeComponent.workspaceNodes;

    for (var targetNode in nodes) {
      if (targetNode.id == fromNode.id) continue;

      for (var point in targetNode.connectionPoints) {
        if (point is! ConnectConnectionPoint) continue;

        final pointPos = targetNode.position + point.computeOffset(targetNode);
        if ((endPos! - pointPos).distance <= 20) {
          bool isTopTarget = point.isTop;

          if (isTop == isTopTarget) continue;

          NodeModel parent, child;

          if (!isTop && isTopTarget) {
            parent = fromNode;
            child = targetNode;
          } else {
            parent = targetNode;
            child = fromNode;
          }

          parent.connectNode(child);
          provider.clear();
          return;
        }
      }
    }

    provider.clear();
  }
  
  @override
  void disconnect(NodeModel owner) {
    if(isTop){
      owner.disconnectIfTop();
    }else{
      owner.disconnectIfBottom();
    }
  }
}
