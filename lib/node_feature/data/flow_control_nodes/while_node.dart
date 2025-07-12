import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/flow_control_node_widgets/while_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class WhileNode extends InputOutputNode {
  WhileNode({
    super.position,
   
  }) : super(
          image: 'assets/icons/while_node.png',
          color: Colors.cyan,
          width: 200,
          height: 200,
          connectionPoints: [],
        ) {
    connectionPoints = [
      InputConnectionPoint(position: Offset.zero, width: 50, ownerNode: this),
      OutputConnectionPoint(position: Offset.zero, width: 50, ownerNode: this),
      ConnectConnectionPoint(position: Offset.zero, isTop: true, width: 50, ownerNode: this),
      ConnectConnectionPoint(position: Offset.zero, isTop: false, width: 50, ownerNode: this),
    ];
  }

  @override
  Result<bool> execute([Entity? activeEntity,Duration? dt]) {
    if (input == null) {
      return Result.failure(
          errorMessage: "WhileNode is missing a condition input.");
    }

    if (output == null) {
      return Result.failure(
          errorMessage: "WhileNode is missing a statement output.");
    }

    while (true) {
      final conditionResult = input!.execute(activeEntity);
      if (conditionResult is! Result<bool>) {
        return Result.failure(
            errorMessage: "Condition did not return a boolean.");
      }

      if (conditionResult.errorMessage != null) {
        return Result.failure(
            errorMessage: "Condition error: ${conditionResult.errorMessage}");
      }

      if (conditionResult.result != true) {
        return Result.success(result: false); // Exit loop
      }

      final bodyResult = output!.execute(activeEntity);
      if (bodyResult.errorMessage != null) {
        return Result.failure(
            errorMessage: "Loop body error: ${bodyResult.errorMessage}");
      }
    }
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: WhileNodeWidget(nodeModel: this),
    );
  }

  @override
NodeModel copyWith({
  Offset? position,
  Color? color,
  double? width,
  double? height,
  bool? isConnected,
  NodeModel? child,
  NodeModel? parent,
  NodeModel? input,
  NodeModel? output,
  List<ConnectionPointModel>? connectionPoints,
}) {
  final newNode = WhileNode(
    position: position ?? this.position,
  );

  newNode.isConnected = isConnected ?? this.isConnected;
  newNode.child = child ?? this.child?.copy();
  newNode.parent = null;
  newNode.input = null;
  newNode.output = null;

  newNode.connectionPoints = connectionPoints != null
      ? connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList()
      : this.connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList();

  return newNode;
}


  @override
  WhileNode copy() {
    return copyWith() as WhileNode;
  }

  @override
Map<String, dynamic> baseToJson() {
  final map = super.baseToJson();
  map['type'] = 'WhileNode';
  return map;
}

static WhileNode fromJson(Map<String, dynamic> json) {
  final node = WhileNode(
    position: OffsetJson.fromJson(json['position']),
  )
    ..id = json['id']
    ..isConnected = json['isConnected'] ?? false;

  node.connectionPoints = (json['connectionPoints'] as List)
      .map((e) => ConnectionPointModel.fromJson(e, node))
      .toList();

  return node;
}


}
