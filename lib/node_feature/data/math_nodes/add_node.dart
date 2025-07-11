import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/math_node_widgets/math_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class AddNode extends NodeModel {
  AddNode({super.position})
      : super(
          image: 'assets/icons/addNode.png',
          color: Colors.blue,
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
  Result execute([Entity? activeEntity]) {
    final a = _getValueFromInput(0, activeEntity);
    final b = _getValueFromInput(1, activeEntity);

    if (a == null || b == null) {
      return Result.failure(errorMessage: "Missing inputs for addition.");
    }

    final result = a + b;

    // Send result to output connection point
    final outputPoint = connectionPoints[2] as ValueConnectionPoint;
    outputPoint.value = result;

    return Result.success(result: result);
  }

  double? _getValueFromInput(int index, Entity? entity) {
    final cp = connectionPoints[index] as ValueConnectionPoint;
    final source = cp.sourcePoint?.ownerNode;
    if (source == null) return null;

    final result = source.execute(entity);
    if (result.errorMessage != null || result.result == null) return null;

    final value = result.result;
    if (value is num) return value.toDouble();
    return null;
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child:  MathNodeWidget(label: '+', node: this,),
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
    final newNode = AddNode(position: position ?? this.position)
      ..isConnected = isConnected ?? this.isConnected
      ..child = null
      ..parent = null;

    newNode.connectionPoints = connectionPoints != null
        ? connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList()
        : this.connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList();

    return newNode;
  }

  @override
  AddNode copy() => copyWith();

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'AddNode';
    return map;
  }

  static AddNode fromJson(Map<String, dynamic> json) {
    final node = AddNode(position: OffsetJson.fromJson(json['position']))
      ..id = json['id']
      ..isConnected = json['isConnected'] ?? false;

    node.connectionPoints = (json['connectionPoints'] as List)
        .map((e) => ConnectionPointModel.fromJson(e, node))
        .toList();

    return node;
  }
}
