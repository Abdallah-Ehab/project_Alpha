import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/math_node_widgets/math_node_widget.dart';

class MultiplyNode extends MultipleInputNode {
  MultiplyNode({super.position})
      : super(
          image: 'assets/icons/multiply.png',
          color: Colors.green,
          width: 160,
          height: 120,
          connectionPoints: [],
        ) {
    connectionPoints = [
      InputConnectionPoint(position: Offset.zero, width: 30, ownerNode: this),
      InputConnectionPoint(position: Offset.zero, width: 30, ownerNode: this),
      ConnectConnectionPoint(
          position: Offset.zero, isTop: true, width: 30, ownerNode: this),
      ConnectConnectionPoint(
          position: Offset.zero, isTop: false, width: 30, ownerNode: this),
    ];
  }

  @override
  Result execute([Entity? activeEntity]) {
    final a = _getInputValue(0, activeEntity);
    final b = _getInputValue(1, activeEntity);

    if (a == null || b == null) {
      return Result.failure(errorMessage: 'Missing inputs for multiplication.');
    }

    return Result.success(result: a * b);
  }

  double? _getInputValue(int index, Entity? activeEntity) {
    final inputNode = getInput(index);
    if (inputNode == null) return null;

    final result = inputNode.execute(activeEntity);
    if (result.errorMessage != null) return null;

    return result.result is num ? result.result.toDouble() : null;
  }

  @override
  Widget buildNode() => ChangeNotifierProvider.value(
        value: this,
        child: MathNodeWidget(node: this, label: '×'),
      );

 
  @override
MultiplyNode copyWith({
  NodeModel? child,
  Color? color,
  List<ConnectionPointModel>? connectionPoints,
  double? height,
  bool? isConnected,
  NodeModel? parent,
  Offset? position,
  double? width,
}) {
  final newNode = MultiplyNode(
    position: position ?? this.position,
  );

  newNode.child = null;
  newNode.parent = null;
  newNode.isConnected = isConnected ?? this.isConnected;
  newNode.color = color ?? this.color;
  newNode.width = width ?? this.width;
  newNode.height = height ?? this.height;

  newNode.connectionPoints = connectionPoints != null
      ? connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList()
      : this.connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList();

  return newNode;
}


  @override
  MultiplyNode copy() => copyWith();
}
