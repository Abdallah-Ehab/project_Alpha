import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/player_transform_node_widgets/teleport_node_widget.dart';

class TeleportNode extends InputOutputNode {
  TeleportNode({Offset? position})
      : super(
          position: position ?? Offset.zero,
          color: Colors.orange,
          width: 180,
          height: 160,
          connectionPoints: [
            InputConnectionPoint(position: Offset.zero, width: 30),
            ValueConnectionPoint(position: Offset.zero, width: 30, valueIndex: 0),
            ValueConnectionPoint(position: Offset.zero, width: 30, valueIndex: 1),
            ConnectConnectionPoint(position: Offset.zero, isTop: true, width: 30),
            ConnectConnectionPoint(position: Offset.zero, isTop: false, width: 30),
          ],
        );

  @override
  Result execute([Entity? activeEntity]) {
    if (activeEntity == null) {
      return Result.failure(errorMessage: "No active entity");
    }

    Result? inputResult;
    if (input != null) {
      inputResult = input!.execute(activeEntity);
      if (inputResult.errorMessage != null) return inputResult;
    } else {
      inputResult = Result.success(result: null);
    }

    dynamic dx = (connectionPoints[1] as ValueConnectionPoint)
        .processValue(inputResult, input ?? this);
    dynamic dy = (connectionPoints[2] as ValueConnectionPoint)
        .processValue(inputResult, input ?? this);

    if (dx == null && dy == null) {
      return Result.failure(errorMessage: "No dx or dy input connected");
    }

    activeEntity.teleport(dx: dx as double, dy: dy as double);
    log("Teleported entity to $dx, $dy");

    return output?.execute(activeEntity) ?? Result.success(result: null);
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: TeleportNodeWidget(nodeModel: this),
    );
  }

  @override
  TeleportNode copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    List<ConnectionPointModel>? connectionPoints,
  }) {
    return TeleportNode(position: position ?? this.position)
      ..isConnected = isConnected ?? this.isConnected
      ..child = child ?? this.child?.copy()
      ..parent = parent ?? this.parent?.copy()
      ..connectionPoints = connectionPoints ??
          List<ConnectionPointModel>.from(this.connectionPoints.map((cp) => cp.copy()));
  }

  @override
  TeleportNode copy() {
    return copyWith(
      position: position,
      isConnected: isConnected,
      child: child?.copy(),
      parent: parent?.copy(),
      connectionPoints:
          List<ConnectionPointModel>.from(connectionPoints.map((cp) => cp.copy())),
    );
  }
}

