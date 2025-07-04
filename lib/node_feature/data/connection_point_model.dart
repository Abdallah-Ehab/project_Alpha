import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity.dart';
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
  final NodeModel ownerNode;

  ConnectionPointModel({
    required this.position,
    required this.color,
    required this.width,
    required this.ownerNode,
    this.isConnected = false,
  }) : id = const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'type': runtimeType.toString(),
      'id': id,
      'position': {'dx': position.dx, 'dy': position.dy},
      'width': width,
      'isConnected': isConnected,
      // Note: We don't serialize ownerNode to avoid circular references
      ..._extraData(),
    };
  }

  Map<String, dynamic> _extraData() {
    if (this is ConnectConnectionPoint) {
      return {'isTop': (this as ConnectConnectionPoint).isTop};
    } else if (this is ValueConnectionPoint) {
      return {
        'valueIndex': (this as ValueConnectionPoint).valueIndex,
        'isLeft': (this as ValueConnectionPoint).isLeft,
      };
    }
    return {};
  }

  static ConnectionPointModel fromJson(
      Map<String, dynamic> json, NodeModel ownerNode) {
    final position = Offset(
      (json['position']['dx'] as num).toDouble(),
      (json['position']['dy'] as num).toDouble(),
    );
    final width = (json['width'] as num).toDouble();
    final isConnected = json['isConnected'] as bool;

    switch (json['type']) {
      case 'InputConnectionPoint':
        return InputConnectionPoint(
          position: position,
          width: width,
          ownerNode: ownerNode,
        )..isConnected = isConnected;
      case 'OutputConnectionPoint':
        return OutputConnectionPoint(
          position: position,
          width: width,
          ownerNode: ownerNode,
        )..isConnected = isConnected;
      case 'ConnectConnectionPoint':
        return ConnectConnectionPoint(
          position: position,
          width: width,
          isTop: json['isTop'] as bool,
          ownerNode: ownerNode,
        )..isConnected = isConnected;
      case 'ValueConnectionPoint':
        return ValueConnectionPoint(
          isLeft: json['isLeft'] as bool,
          position: position,
          width: width,
          valueIndex: json['valueIndex'] as int,
          ownerNode: ownerNode,
          isConnected: isConnected,
        );
      default:
        throw UnimplementedError(
          'Unknown ConnectionPointModel type: ${json['type']}',
        );
    }
  }

  Widget build(BuildContext context) {
    return Positioned(
      top: computeOffset().dy,
      left: computeOffset().dx,
      child: ConnectionPointWidget(
        connectionPoint: this,
        node: ownerNode,
      ),
    );
  }

  Offset computeOffset();
  void handlePanEndBehaviour(BuildContext context);
  void disconnect();
  ConnectionPointModel copyWith({
    Offset? position,
    Color? color,
    double? width,
    bool? isConnected,
    NodeModel? ownerNode,
  });

  ConnectionPointModel copy();
}

class InputConnectionPoint extends ConnectionPointModel {
  InputConnectionPoint({
    required super.position,
    required super.width,
    required super.ownerNode,
  }) : super(color: Colors.redAccent);

  @override
  ConnectionPointModel copyWith({
    Offset? position,
    Color? color,
    double? width,
    bool? isConnected,
    NodeModel? ownerNode,
  }) {
    return InputConnectionPoint(
      position: position ?? this.position,
      width: width ?? this.width,
      ownerNode: ownerNode ?? this.ownerNode,
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
  Offset computeOffset() {
    return Offset(-width / 2, ownerNode.height / 2 - width / 2);
  }

  @override
  void handlePanEndBehaviour(BuildContext context) {
    // Input points don't initiate connections
    return;
  }

  @override
  void disconnect() {
    if (ownerNode is HasOutput) {
      (ownerNode as HasOutput).disconnectOutput();
    }
    isConnected = false;
  }
}

class OutputConnectionPoint extends ConnectionPointModel {
  OutputConnectionPoint({
    required super.position,
    required super.width,
    required super.ownerNode,
  }) : super(color: Colors.greenAccent);

  @override
  ConnectionPointModel copyWith({
    Offset? position,
    Color? color,
    double? width,
    bool? isConnected,
    NodeModel? ownerNode,
  }) {
    return OutputConnectionPoint(
      position: position ?? this.position,
      width: width ?? this.width,
      ownerNode: ownerNode ?? this.ownerNode,
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
  Offset computeOffset() {
    return Offset(
        ownerNode.width - width / 2, ownerNode.height / 2 - width / 2);
  }

  @override
  void disconnect() {
    if (ownerNode is HasInput) {
      (ownerNode as HasInput).disconnectInput();
    }
    isConnected = false;
  }

  @override
  void handlePanEndBehaviour(BuildContext context) {
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
      if (targetNode.id == ownerNode.id) continue;

      for (var point in targetNode.connectionPoints) {
        if (point is! InputConnectionPoint) continue;

        final pointPos = targetNode.position + point.computeOffset();
        if ((endPos - pointPos).distance <= 20) {
          if (ownerNode is HasOutput && targetNode is HasInput) {
            (ownerNode as HasOutput).connectOutput(targetNode);
            (targetNode as HasInput).connectInput(ownerNode);
            isConnected = true;
            point.isConnected = true;
            log('output node $ownerNode is connected to input node $targetNode');
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

  ConnectConnectionPoint({
    required super.position,
    required this.isTop,
    required super.width,
    required super.ownerNode,
  }) : super(color: Colors.grey);

  @override
  ConnectionPointModel copyWith({
    Offset? position,
    Color? color,
    double? width,
    bool? isConnected,
    bool? isTop,
    NodeModel? ownerNode,
  }) {
    return ConnectConnectionPoint(
      position: position ?? this.position,
      isTop: isTop ?? this.isTop,
      width: width ?? this.width,
      ownerNode: ownerNode ?? this.ownerNode,
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
  Offset computeOffset() {
    return isTop
        ? Offset(ownerNode.width / 2 - width / 2, -width / 2)
        : Offset(ownerNode.width / 2 - width / 2, ownerNode.height - width / 2);
  }

  @override
  void handlePanEndBehaviour(BuildContext context) {
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

    if (endPos == null) {
      provider.clear();
      return;
    }

    for (var targetNode in nodes) {
      if (targetNode.id == ownerNode.id) continue;

      for (var point in targetNode.connectionPoints) {
        if (point is! ConnectConnectionPoint) continue;

        final pointPos = targetNode.position + point.computeOffset();
        if ((endPos - pointPos).distance <= 20) {
          bool isTopTarget = point.isTop;

          if (isTop == isTopTarget) continue;

          NodeModel parent, child;

          if (!isTop && isTopTarget) {
            parent = ownerNode;
            child = targetNode;
          } else {
            parent = targetNode;
            child = ownerNode;
          }

          parent.connectNode(child);
          isConnected = true;
          point.isConnected = true;
          provider.clear();
          return;
        }
      }
    }

    provider.clear();
  }

  @override
  void disconnect() {
    if (isTop) {
      ownerNode.disconnectIfTop();
    } else {
      ownerNode.disconnectIfBottom();
    }
    isConnected = false;
  }
}

class ValueConnectionPoint extends ConnectionPointModel {
  int valueIndex;
  ValueConnectionPoint? sourcePoint;
  ValueConnectionPoint? destinationPoint;
  bool isLeft;
  dynamic value;

  ValueConnectionPoint({
    required super.ownerNode,
    required this.isLeft,
    required super.position,
    required this.valueIndex,
    required super.width,
    super.isConnected = false,
  }) : super(color: Colors.purple);

  @override
  ConnectionPointModel copyWith({
    Offset? position,
    Color? color,
    double? width,
    bool? isConnected,
    NodeModel? ownerNode,
  }) {
    return ValueConnectionPoint(
      isLeft: isLeft,
      position: position ?? this.position,
      valueIndex: valueIndex,
      width: width ?? this.width,
      isConnected: isConnected ?? this.isConnected,
      ownerNode: ownerNode ?? this.ownerNode,
    )
      ..sourcePoint = null
      ..destinationPoint = destinationPoint
      ..value = value;
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
  Offset computeOffset() {
    return isLeft
        ? Offset(
            -width / 2,
            ownerNode.height / 4 -
                width / 2 +
                valueIndex * (ownerNode.height / 2))
        : Offset(
            ownerNode.width - width / 2,
            ownerNode.height / 4 -
                width / 2 +
                valueIndex * (ownerNode.height / 2));
  }

  @override
  void handlePanEndBehaviour(BuildContext context) {
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
      if (targetNode.id == ownerNode.id) continue;

      for (var targetPoint in targetNode.connectionPoints) {
        if (targetPoint is! ValueConnectionPoint) continue;

        final targetPointPos =
            targetNode.position + targetPoint.computeOffset();
        if ((endPos - targetPointPos).distance <= 20) {
          if (targetNode is OutputNodeWithValue && ownerNode is InputNodeWithValue) {
            (ownerNode as InputNodeWithValue).connectValue(this, targetPoint);
            isConnected = true;
            targetPoint.isConnected = true;
            log('ValueConnectionPoint $valueIndex on $targetNode connected to $ownerNode');
            provider.clear();
            return;
          }
        }
      }
    }

    provider.clear();
  }

  dynamic processValue([Entity? activeEntity]) {
    if (!isConnected || sourcePoint == null) return value;

    final result = sourcePoint!.ownerNode.execute(activeEntity);
    if (result.errorMessage != null || result.result == null) return null;

    final fullValue = result.result;
    if (fullValue is Offset) {
      return valueIndex == 0 ? fullValue.dx : fullValue.dy;
    }

    if (fullValue is List && valueIndex < fullValue.length) {
      return fullValue[valueIndex];
    }

    return fullValue;
  }

  @override
  void disconnect() {}
}
