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
  bool isConnected;
  ConnectionPointModel(
      {required this.position, required this.color, required this.width,this.isConnected = false})
      : id = const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'type': runtimeType.toString(),
      'id': id,
      'position': {'dx': position.dx, 'dy': position.dy},
      'width': width,
      'isConnected': isConnected,
      ..._extraData(),
    };
  }

  Map<String, dynamic> _extraData() {
    if (this is ConnectConnectionPoint) {
      return {'isTop': (this as ConnectConnectionPoint).isTop};
    } else if (this is ValueConnectionPoint) {
      return {
        'valueIndex': (this as ValueConnectionPoint).valueIndex,
        'sourceNodeId': (this as ValueConnectionPoint).sourceNode?.id,
      };
    }
    return {};
  }

  static ConnectionPointModel fromJson(Map<String, dynamic> json) {
    final position = Offset(
      (json['position']['dx'] as num).toDouble(),
      (json['position']['dy'] as num).toDouble(),
    );
    final width = (json['width'] as num).toDouble();
    final isConnected = json['isConnected'] as bool;

    switch (json['type']) {
      case 'InputConnectionPoint':
        return InputConnectionPoint(position: position, width: width)
          ..isConnected = isConnected;
      case 'OutputConnectionPoint':
        return OutputConnectionPoint(position: position, width: width)
          ..isConnected = isConnected;
      case 'ConnectConnectionPoint':
        return ConnectConnectionPoint(
          position: position,
          width: width,
          isTop: json['isTop'] as bool,
        )..isConnected = isConnected;
      case 'ValueConnectionPoint':
        return ValueConnectionPoint(
          isLeft: json['isLeft'] as bool,
          position: position,
          width: width,
          valueIndex: json['valueIndex'] as int,
          isConnected: isConnected,
        );
      default:
        throw UnimplementedError(
          'Unknown ConnectionPointModel type: ${json['type']}',
        );
    }
  }

  Widget build(BuildContext context, NodeModel owner);

  Offset computeOffset(NodeModel owner);

  void handlePanEndBehaviour(BuildContext context, NodeModel fromNode);

  void disconnect(NodeModel owner);

  ConnectionPointModel copyWith({Offset? position,Color? color,double? width, bool? isConnected});
  ConnectionPointModel copy();
}

class InputConnectionPoint extends ConnectionPointModel {
  InputConnectionPoint({required super.position, required super.width})
      : super(color: Colors.redAccent);

  @override
  ConnectionPointModel copyWith({Offset? position, Color? color, double? width, bool? isConnected}) {
    return InputConnectionPoint(
      position: position ?? this.position,
      width: width ?? this.width,
    )..isConnected = isConnected ?? this.isConnected;
  }

  @override
  ConnectionPointModel copy() {
    return copyWith(
      position: position,
      width: width,
      isConnected: isConnected,
    );
  }

  @override
  Widget build(BuildContext context, NodeModel owner) {
    return Positioned(
      top: computeOffset(owner).dy,
      left: computeOffset(owner).dx,
      child: ConnectionPointWidget(
        connectionPoint: this,
        node: owner,
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
    if (owner is HasOutput) {
      owner.disconnectOutput();
    }
  }
}
class OutputConnectionPoint extends ConnectionPointModel {
  OutputConnectionPoint({required super.position, required super.width})
      : super(color: Colors.greenAccent);

  @override
  ConnectionPointModel copyWith({
    Offset? position,
    Color? color,
    double? width,
    bool? isConnected,
  }) {
    return OutputConnectionPoint(
      position: position ?? this.position,
      width: width ?? this.width,
    )..isConnected = isConnected ?? this.isConnected;
  }

  @override
  ConnectionPointModel copy() {
    return copyWith(
      position: position,
      width: width,
      isConnected: isConnected,
    );
  }

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
    if (owner is HasInput) {
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
        if (endPos == null) return;
        if ((endPos - pointPos).distance <= 20) {
          if (fromNode is HasOutput && targetNode is HasInput) {
            fromNode.connectOutput(targetNode);
            targetNode.connectInput(fromNode);
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
  ConnectionPointModel copyWith({
    Offset? position,
    Color? color,
    double? width,
    bool? isConnected,
    bool? isTop,
  }) {
    return ConnectConnectionPoint(
      position: position ?? this.position,
      isTop: isTop ?? this.isTop,
      width: width ?? this.width,
    )..isConnected = isConnected ?? this.isConnected;
  }

  @override
  ConnectionPointModel copy() {
    return copyWith(
      position: position,
      isTop: isTop,
      width: width,
      isConnected: isConnected,
    );
  }

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
    if (isTop) {
      owner.disconnectIfTop();
    } else {
      owner.disconnectIfBottom();
    }
  }
}

class ValueConnectionPoint extends ConnectionPointModel {
  NodeModel? sourceNode;
  int valueIndex;
  int? sourceIndex;
  bool isLeft;
  ValueConnectionPoint({
    required this.isLeft,
    required super.position,
    required this.valueIndex,
    required super.width,
    super.isConnected,
  }) : super(color: Colors.purple);

  @override
  ConnectionPointModel copyWith({
    Offset? position,
    Color? color,
    double? width,
    bool? isConnected,
    NodeModel? sourceNode,
    int? valueIndex,
    bool? isLeft
  }) {
    return ValueConnectionPoint(
      isLeft: isLeft ?? this.isLeft,
      position: position ?? this.position,
      valueIndex: valueIndex ?? this.valueIndex,
      width: width ?? this.width,
      isConnected: isConnected ?? this.isConnected,
    )..sourceNode = sourceNode ?? this.sourceNode;
  }

  @override
  ConnectionPointModel copy() {
    return copyWith(
      position: position,
      valueIndex: valueIndex,
      width: width,
      isConnected: isConnected,
      sourceNode: sourceNode?.copy(), // Deep copy the source node if present
    );
  }

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
    return isLeft ? Offset(width / 2, owner.height / 4 - width / 2 + valueIndex * (owner.height / 2)) : Offset(owner.width / 2 - width / 2, owner.height / 4 - width / 2 + valueIndex * (owner.height / 2));
    // Positions: first value at top (height/4), second at bottom (3*height/4)
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

    if (endPos == null) {
      provider.clear();
      return;
    }

    for (var targetNode in nodes) {
      if (targetNode.id == fromNode.id) continue;

      for (var targetPoint in targetNode.connectionPoints) {
        if (targetPoint is! ValueConnectionPoint) continue; // Only connect to ValueConnectionPoint

        final targetPointPos = targetNode.position + targetPoint.computeOffset(targetNode);
        if ((endPos - targetPointPos).distance <= 20) {
          if (targetNode is OutputNodeWithValue && targetPoint.sourceNode == null) {
           
            targetPoint.isConnected = true;
            targetPoint.sourceIndex = valueIndex;
            targetNode.connectValue(fromNode);
            log('ValueConnectionPoint $valueIndex on $targetNode connected to $fromNode');
            provider.clear();
            return;
          }
        }
      }
    }

    provider.clear();
  }

  dynamic processValue(dynamic result) {
    if (sourceNode == null || !isConnected) return null;
    if (result.errorMessage != null) return null;
    final value = result.result;
    if (value is List && sourceIndex != null && value.length > sourceIndex!) {
      return value[sourceIndex!];
    }

    return value;
  }
  
  @override
  void disconnect(NodeModel owner) {
    if (owner is HasValue) {
      owner.disconnect();
    }
  }
}