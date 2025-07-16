import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/player_transform_node_widgets/move_for_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class MoveForSecondsNode extends NodeModel {
  double dx;
  double dy;
  double duration;
  
  // Track time between updates like WaitForNode does
  Duration? _lastUpdate;
  double _accumulatedTime = 0.0;
  
  MoveForSecondsNode({
    this.dx = 0.0,
    this.dy = 0.0,
    this.duration = 1.0,
    super.position = Offset.zero,
  }) : super(
          image: 'assets/icons/moveNode.png',
          connectionPoints: [],
          color: Colors.purple,
          width: 200,
          height: 120,
        ) {
    connectionPoints = [
      ConnectConnectionPoint(position: Offset.zero, isTop: true, width: 20, ownerNode: this),
      ConnectConnectionPoint(position: Offset.zero, isTop: false, width: 20, ownerNode: this),
    ];
  }

  @override
  Result<bool> execute([Entity? activeEntity, Duration? dt]) {
    if (activeEntity == null || dt == null) {
      return Result.failure(errorMessage: "No entity or delta time");
    }

    // Initialize on first call
    if (_lastUpdate == null) {
      _lastUpdate = dt;
      _accumulatedTime = 0.0;
      log('Starting movement for ${duration}s');
      return Result.success(result: false);
    }

    // Calculate actual delta time between frames
    final delta = dt - _lastUpdate!;
    final deltaSeconds = delta.inMicroseconds / 1e6;
    _lastUpdate = dt;
    
    // Apply movement based on delta time (smooth movement)
    activeEntity.move(x: dx * deltaSeconds, y: dy * deltaSeconds);
    
    // Accumulate time
    _accumulatedTime += deltaSeconds;
    
    log('Movement delta: ${deltaSeconds}s, accumulated: ${_accumulatedTime}s/${duration}s');
    
    if (_accumulatedTime >= duration) {
      log('Movement completed');
      _accumulatedTime = 0.0;
      _lastUpdate = null;
      return Result.success(result: true); // Done, continue to next node
    }

    return Result.success(result: false); // Not done yet, stay on this node
  }

  void setDx(double value) {
    dx = value;
    notifyListeners();
  }

  void setDy(double value) {
    dy = value;
    notifyListeners();
  }

  void setDuration(double value) {
    duration = value;
    notifyListeners();
  }

  @override
  void reset() {
    _accumulatedTime = 0.0;
    _lastUpdate = null;
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: MoveForSecondsNodeWidget(node: this),
    );
  }

  @override
  MoveForSecondsNode copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    List<ConnectionPointModel>? connectionPoints,
    double? dx,
    double? dy,
    double? duration,
  }) {
    final newNode = MoveForSecondsNode(
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      duration: duration ?? this.duration,
    )
      ..position = position ?? this.position
      ..isConnected = isConnected ?? this.isConnected
      ..child = null
      ..parent = null;

    newNode.connectionPoints = connectionPoints != null
        ? connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList()
        : this.connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList();

    return newNode;
  }

  @override
  MoveForSecondsNode copy() => copyWith();

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'MoveForSecondsNode';
    map['dx'] = dx;
    map['dy'] = dy;
    map['duration'] = duration;
    return map;
  }

  static MoveForSecondsNode fromJson(Map<String, dynamic> json) {
    final moveNode = MoveForSecondsNode(
      dx: (json['dx'] as num).toDouble(),
      dy: (json['dy'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
      position: OffsetJson.fromJson(json['position']),
    )
      ..id = json['id']
      ..isConnected = json['isConnected'] ?? false;

    moveNode.connectionPoints = (json['connectionPoints'] as List)
        .map((e) => ConnectionPointModel.fromJson(e, moveNode))
        .toList();

    return moveNode;
  }
}