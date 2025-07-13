
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/player_transform_node_widgets/wait_for_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class WaitForNode extends NodeModel {
  double waitSeconds;

  /// Used to track time between updates
  Duration? _lastUpdate;
  double _accumulatedTime = 0.0;

  WaitForNode({
    this.waitSeconds = 1.0,
    super.position = Offset.zero,
  }) : super(
          image: 'assets/icons/wait for node.png',
          connectionPoints: [],
          color: Colors.orange,
          width: 200,
          height: 100,
        ) {
    connectionPoints = [
      ConnectConnectionPoint(
          position: Offset.zero, isTop: true, width: 20, ownerNode: this),
      ConnectConnectionPoint(
          position: Offset.zero, isTop: false, width: 20, ownerNode: this),
    ];
  }

  @override
  Result<bool> execute([Entity? activeEntity, Duration? dt = Duration.zero]) {
    if (_lastUpdate == null) {
      _lastUpdate = dt;
      return Result.success(result: false);
    }

    final delta = dt! - _lastUpdate!;
    _accumulatedTime += delta.inMicroseconds / 1e6;
    _lastUpdate = dt;

    if (_accumulatedTime >= waitSeconds) {
      _accumulatedTime = 0.0;
      _lastUpdate = null;
      return Result.success(result: true);
    }

    return Result.success(result: false);
  }

  void setWaitSeconds(double value) {
    waitSeconds = value;
    notifyListeners();
  }

  @override
  void reset(){
    _accumulatedTime = 0.0;
    _lastUpdate = null;
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: WaitForNodeWidget(node: this),
    );
  }

  @override
  WaitForNode copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    List<ConnectionPointModel>? connectionPoints,
    double? waitSeconds,
  }) {
    final newNode = WaitForNode(
      waitSeconds: waitSeconds ?? this.waitSeconds,
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
  WaitForNode copy() {
    return copyWith();
  }

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'WaitForNode';
    map['waitSeconds'] = waitSeconds;
    return map;
  }

  static WaitForNode fromJson(Map<String, dynamic> json) {
    final waitNode = WaitForNode(
      waitSeconds: (json['waitSeconds'] as num).toDouble(),
      position: OffsetJson.fromJson(json['position']),
    )
      ..id = json['id']
      ..isConnected = json['isConnected'] ?? false;

    waitNode.connectionPoints = (json['connectionPoints'] as List)
        .map((e) => ConnectionPointModel.fromJson(e, waitNode))
        .toList();

    return waitNode;
  }
}
