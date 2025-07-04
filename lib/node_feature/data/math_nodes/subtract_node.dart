import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/math_node_widgets/math_node_widget.dart';

class DivideNode extends MultipleInputNode {
  DivideNode({super.position})
      : super(
          image: 'assets/icons/divide.png',
          color: Colors.purple,
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

    if (a == null || b == null || b == 0) {
      return Result.failure(errorMessage: 'Invalid inputs for division.');
    }

    return Result.success(result: a / b);
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
        child: MathNodeWidget(node: this, label: '÷'),
      );

@override
DivideNode copyWith({
  NodeModel? child,
  Color? color,
  List<ConnectionPointModel>? connectionPoints,
  double? height,
  bool? isConnected,
  NodeModel? parent,
  Offset? position,
  double? width,
}) {
  final newNode = DivideNode(
    position: position ?? this.position,
  );

  newNode.parent = null;
  newNode.child = null;
  newNode.isConnected = isConnected ?? this.isConnected;

  newNode.connectionPoints = connectionPoints != null
      ? connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList()
      : this.connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList();

  return newNode;
}

  @override
  DivideNode copy() => copyWith();
}
