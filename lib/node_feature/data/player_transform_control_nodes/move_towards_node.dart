import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/player_transform_node_widgets/move_towards_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class MoveTowardsNode extends InputNodeWithValue{
  double speed;
  double targetX;
  double targetY;

  Duration? _lastUpdate;

  MoveTowardsNode({
    this.speed = 100.0,
    this.targetX = 0.0,
    this.targetY = 0.0,
    super.position = Offset.zero,
  }) : super(
          image: 'assets/icons/moveNode.png',
          connectionPoints: [],
          color: Colors.blue,
          width: 200,
          height: 200,
        ) {
    connectionPoints = [
      ConnectConnectionPoint(position: Offset.zero, isTop: true, width: 30, ownerNode: this),
      ConnectConnectionPoint(position: Offset.zero, isTop: false, width: 30, ownerNode: this),
      ValueConnectionPoint(
        position: Offset.zero,
        width: 30,
        valueIndex: 0,
        isLeft: true,
        ownerNode: this,
      ), // targetX
      ValueConnectionPoint(
        position: Offset.zero,
        width: 30,
        valueIndex: 1,
        isLeft: true,
        ownerNode: this,
      ), // targetY
      ValueConnectionPoint(
        position: Offset.zero,
        width: 30,
        valueIndex: 2,
        isLeft: true,
        ownerNode: this,
      ), // speed (optional)
    ];
  }

  @override
  Result<bool> execute([Entity? activeEntity, Duration? dt]) {
    if (activeEntity == null || dt == null) {
      return Result.failure(errorMessage: "No entity or delta time");
    }

    final targetXValue = _getValueFromPoint(connectionPoints[2] as ValueConnectionPoint, activeEntity) ?? targetX;
    final targetYValue = _getValueFromPoint(connectionPoints[3] as ValueConnectionPoint, activeEntity) ?? targetY;
    final customSpeed = _getValueFromPoint(connectionPoints[4] as ValueConnectionPoint, activeEntity);

    final effectiveSpeed = customSpeed ?? speed;

    if (_lastUpdate == null) {
      _lastUpdate = dt;
      return Result.success(result: false); // Start movement
    }

    // Calculate delta time from real time
    final delta = dt - _lastUpdate!;
    final deltaSeconds = delta.inMicroseconds / 1e6;
    _lastUpdate = dt;

    final current = activeEntity.position;
    final target = Offset(targetXValue, targetYValue);
    final direction = target - current;
    final distance = direction.distance;

    if (distance < 0.1) {
      reset();
      return Result.success(result: true); // Done
    }

    final stepLength = effectiveSpeed * deltaSeconds;
    final movement = stepLength >= distance
        ? direction
        : direction / distance * stepLength;

    activeEntity.move(x: movement.dx, y: movement.dy);
    return Result.success(result: false); // Still in progress
  }

  double? _getValueFromPoint(ValueConnectionPoint point, Entity activeEntity) {
    final source = point.sourcePoint?.ownerNode;
    if (source == null) return null;

    final result = source.execute(activeEntity);
    if (result.errorMessage != null || result.result == null) return null;

    final value = result.result;
    if (value is List && point.sourcePoint!.valueIndex < value.length) {
      return (value[point.sourcePoint!.valueIndex])?.toDouble();
    } else if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  @override
  void reset() {
    _lastUpdate = null;
  }

  void setSpeed(double value) {
    speed = value;
    notifyListeners();
  }

  void setTargetX(double value) {
    targetX = value;
    notifyListeners();
  }

  void setTargetY(double value) {
    targetY = value;
    notifyListeners();
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: MoveTowardsNodeWidget(node: this),
    );
  }

  @override
  MoveTowardsNode copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    List<ConnectionPointModel>? connectionPoints,
    double? speed,
    double? targetX,
    double? targetY,
  }) {
    final newNode = MoveTowardsNode(
      speed: speed ?? this.speed,
      targetX: targetX ?? this.targetX,
      targetY: targetY ?? this.targetY,
      position: position ?? this.position,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = null
      ..parent = null;

    newNode.connectionPoints = connectionPoints != null
        ? connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList()
        : this.connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList();

    return newNode;
  }

  @override
  MoveTowardsNode copy() => copyWith();

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'MoveTowardsNode';
    map['speed'] = speed;
    map['targetX'] = targetX;
    map['targetY'] = targetY;
    return map;
  }

  static MoveTowardsNode fromJson(Map<String, dynamic> json) {
    final node = MoveTowardsNode(
      speed: (json['speed'] as num).toDouble(),
      targetX: (json['targetX'] as num?)?.toDouble() ?? 0.0,
      targetY: (json['targetY'] as num?)?.toDouble() ?? 0.0,
      position: OffsetJson.fromJson(json['position']),
    )
      ..id = json['id']
      ..isConnected = json['isConnected'] ?? false;

    node.connectionPoints = (json['connectionPoints'] as List)
        .map((e) => ConnectionPointModel.fromJson(e, node))
        .toList();

    return node;
  }
}