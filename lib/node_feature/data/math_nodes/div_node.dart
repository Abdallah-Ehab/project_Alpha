import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/math_node_widgets/math_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class DivideNode extends InputNodeWithValue {
  double a;
  double b;

  DivideNode({this.a = 0, this.b = 1, super.position})
      : super(
          image: 'assets/icons/divideNode.png',
          color: Colors.deepPurple,
          width: 160,
          height: 200,
          connectionPoints: [],
        ) {
    connectionPoints = [
      ConnectConnectionPoint(position: Offset.zero, isTop: true, width: 30, ownerNode: this),
      ValueConnectionPoint(position: Offset.zero, width: 30, valueIndex: 0, isLeft: true, ownerNode: this),
      ValueConnectionPoint(position: Offset.zero, width: 30, valueIndex: 1, isLeft: true, ownerNode: this),
      ValueConnectionPoint(position: Offset.zero, width: 30, valueIndex: 0, isLeft: false, ownerNode: this),
      ConnectConnectionPoint(position: Offset.zero, isTop: false, width: 30, ownerNode: this)
    ];
  }

  void setA(double val) {
    a = val;
    notifyListeners();
  }

  void setB(double val) {
    b = val;
    notifyListeners();
  }

  @override
  Result execute([Entity? activeEntity, Duration? dt]) {
    final left = _getInputValue(1, activeEntity) ?? a;
    final right = _getInputValue(2, activeEntity) ?? b;

    if (right == 0) return Result.failure(errorMessage: 'Division by zero.');

    final result = left / right;
    (connectionPoints[3] as ValueConnectionPoint).value = result;

    return Result.success(result: result);
  }

  double? _getInputValue(int index, Entity? entity) {
    final cp = connectionPoints[index] as ValueConnectionPoint;
    final source = cp.sourcePoint?.ownerNode;
    if (source == null) return null;

    final result = source.execute(entity);
    return (result.result is num) ? result.result.toDouble() : null;
  }

  @override
  Widget buildNode() => ChangeNotifierProvider.value(value: this, child: MathNodeWidget(label: '÷', node: this));

  @override
DivideNode copyWith({
  Offset? position,
  double? a,
  double? b,
  Color? color,
  double? width,
  double? height,
  bool? isConnected,
  NodeModel? child,
  NodeModel? parent,
  List<ConnectionPointModel>? connectionPoints,
}) {
  final newNode = DivideNode(
    a: a ?? this.a,
    b: b ?? this.b,
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
  DivideNode copy() => copyWith();

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'DivideNode';
    map['a'] = a;
    map['b'] = b;
    return map;
  }

  static DivideNode fromJson(Map<String, dynamic> json) {
    final node = DivideNode(
      position: OffsetJson.fromJson(json['position']),
      a: (json['a'] ?? 0).toDouble(),
      b: (json['b'] ?? 0).toDouble(),
    );
    node.id = json['id'];
    node.isConnected = json['isConnected'] ?? false;
    node.connectionPoints = (json['connectionPoints'] as List)
        .map((e) => ConnectionPointModel.fromJson(e, node))
        .toList();
    return node;
  }
}
