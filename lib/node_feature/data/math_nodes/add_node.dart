import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/math_node_widgets/math_node_widget.dart';

class AddNode extends MultipleInputNode {
  AddNode({super.position})
      : super(
          image: 'assets/icons/add.png',
          color: Colors.blue,
          width: 160,
          height: 120,
          connectionPoints: [],
        ) {
    connectionPoints = [
      InputConnectionPoint(position: Offset.zero, width: 30, ownerNode: this),
      InputConnectionPoint(position: Offset.zero, width: 30, ownerNode: this),
      ConnectConnectionPoint(position: Offset.zero, isTop: true, width: 30, ownerNode: this),
      ConnectConnectionPoint(position: Offset.zero, isTop: false, width: 30, ownerNode: this),
    ];
  }

  @override
  Result execute([Entity? activeEntity]) {
    final a = _getInputValue(0, activeEntity);
    final b = _getInputValue(1, activeEntity);

    if (a == null || b == null) {
      return Result.failure(errorMessage: 'Missing inputs for addition.');
    }

    return Result.success(result: a + b);
  }

  double? _getInputValue(int index, Entity? activeEntity) {
    final inputNode = getInput(index);
    if (inputNode == null) return null;

    final result = inputNode.execute(activeEntity);
    if (result.errorMessage != null) return null;

    return result.result is num ? result.result.toDouble() : null;
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: MathNodeWidget(node: this, label: '+'),
    );
  }

  @override
AddNode copyWith({
  Offset? position,
  Color? color,
  double? width,
  double? height,
  bool? isConnected,
  NodeModel? child,
  NodeModel? parent,
  List<ConnectionPointModel>? connectionPoints,
}) {
  final newNode = AddNode(position: position ?? this.position);
  newNode.isConnected = isConnected ?? this.isConnected;
  newNode.child = null;
  newNode.parent = null;
  newNode.connectionPoints = connectionPoints != null
      ? connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList()
      : this.connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList();
  return newNode;
}


  @override
  AddNode copy() => copyWith();
}
