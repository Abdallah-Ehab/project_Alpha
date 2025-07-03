import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/math_node_widgets/math_node_widget.dart';

class SubtractNode extends MultipleInputNode {
  SubtractNode({super.position})
      : super(
          image: 'assets/icons/subtract.png',
          color: Colors.red,
          width: 160,
          height: 120,
          connectionPoints: [
            InputConnectionPoint(position: Offset.zero, width: 30),
            InputConnectionPoint(position: Offset.zero, width: 30),
            ConnectConnectionPoint(position: Offset.zero, isTop: true, width: 30),
            ConnectConnectionPoint(position: Offset.zero, isTop: false, width: 30),
          ],
        );

  @override
  Result execute([Entity? activeEntity]) {
    final a = _getInputValue(0, activeEntity);
    final b = _getInputValue(1, activeEntity);

    if (a == null || b == null) {
      return Result.failure(errorMessage: 'Missing inputs for subtraction.');
    }

    return Result.success(result: a - b);
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
        child: MathNodeWidget(node: this, label: '-'),
      );

  @override
  SubtractNode copyWith({
    NodeModel? child,
    Color? color,
    List<ConnectionPointModel>? connectionPoints,
    double? height,
    bool? isConnected,
    NodeModel? parent,
    Offset? position,
    double? width,
  }) {
    return SubtractNode(
      position: position ?? this.position,
    )
    ..child = null
    .. parent = null
    ..isConnected = isConnected ?? this.isConnected
    ..connectionPoints = connectionPoints ??
          List<ConnectionPointModel>.from(this.connectionPoints.map((cp) => cp.copy()));
  }

  @override
  SubtractNode copy() => copyWith();
}
