import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/math_node_widgets/math_node_widget.dart';

class ValueToOutputNode extends InputNodeWithValue {
  ValueToOutputNode({super.position})
      : super(
          color: Colors.indigo,
          width: 120,
          height: 80,
          image: '',
          connectionPoints: [
            ValueConnectionPoint(position: Offset.zero, width: 30, valueIndex: 0,isLeft: true),
            ConnectConnectionPoint(position: Offset.zero, isTop: false, width: 30),
          ],
        );

  @override
  Result execute([Entity? activeEntity]) {
    if (sourceNode == null) {
      return Result.failure(errorMessage: 'No value connected.');
    }

    final result = sourceNode!.execute(activeEntity);
    if (result.errorMessage != null) return result;

    final value = (connectionPoints[1] as ValueConnectionPoint)
        .processValue(result);
        
    return Result.success(result: value);
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: MathNodeWidget(node: this, label: 'Bridge'),
    );
  }

  @override
  @override
  ValueToOutputNode copyWith({
    NodeModel? child,
    Color? color,
    List<ConnectionPointModel>? connectionPoints,
    double? height,
    bool? isConnected,
    NodeModel? parent,
    Offset? position,
    double? width,
  }) {
    return ValueToOutputNode(
      position: position ?? this.position,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..sourceNode = sourceNode
      ..connectionPoints = connectionPoints ?? List<ConnectionPointModel>.from(this.connectionPoints.map((e) => e.copy()));
  }

  @override
  ValueToOutputNode copy() => copyWith();
}
