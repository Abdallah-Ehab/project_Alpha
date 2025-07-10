import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/math_node_widgets/math_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class MultiplyNode extends InputNodeWithValue {
  MultiplyNode({super.position})
      : super(
          image: 'assets/icons/multiplyNode.png',
          color: Colors.green,
          width: 160,
          height: 100,
          connectionPoints: [],
        ) {
    connectionPoints = [
      ValueConnectionPoint(
        position: Offset.zero,
        width: 30,
        valueIndex: 0,
        isLeft: true,
        ownerNode: this,
      ),
      ValueConnectionPoint(
        position: Offset.zero,
        width: 30,
        valueIndex: 1,
        isLeft: true,
        ownerNode: this,
      ),
      ValueConnectionPoint(
        position: Offset.zero,
        width: 30,
        valueIndex: 0,
        isLeft: false,
        ownerNode: this,
      ),
    ];
  }

  @override
  Result execute([Entity? activeEntity,Duration? dt]) {
    final a = _getInputValue(0, activeEntity);
    final b = _getInputValue(1, activeEntity);

    if (a == null || b == null) {
      return Result.failure(errorMessage: 'Missing inputs for multiplication.');
    }

    final result = a * b;
    (connectionPoints[2] as ValueConnectionPoint).value = result;

    return Result.success(result: result);
  }

  double? _getInputValue(int index, Entity? entity) {
    final cp = connectionPoints[index] as ValueConnectionPoint;
    final sourceNode = cp.sourcePoint?.ownerNode;
    if (sourceNode == null) return null;

    final result = sourceNode.execute(entity);
    if (result.errorMessage != null || result.result == null) return null;

    return result.result is num ? result.result.toDouble() : null;
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: MathNodeWidget(label: '×',node: this,),
    );
  }

  @override
  MultiplyNode copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    List<ConnectionPointModel>? connectionPoints,
  }) {
    final newNode = MultiplyNode(position: position ?? this.position)
      ..isConnected = isConnected ?? this.isConnected
      ..child = null
      ..parent = null;

    newNode.connectionPoints = connectionPoints != null
        ? connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList()
        : this.connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList();

    return newNode;
  }

  @override
  MultiplyNode copy() => copyWith();

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'MultiplyNode';
    return map;
  }

  static MultiplyNode fromJson(Map<String, dynamic> json) {
    final node = MultiplyNode(position: OffsetJson.fromJson(json['position']))
      ..id = json['id']
      ..isConnected = json['isConnected'] ?? false;

    node.connectionPoints = (json['connectionPoints'] as List)
        .map((e) => ConnectionPointModel.fromJson(e, node))
        .toList();

    return node;
  }
}
