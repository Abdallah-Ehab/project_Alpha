import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/flow_control_node_widgets/if_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

//Todo the if node will have 4 connection points (input, output, connect,connect)
//the input will be red and it's for the conditions
// the output will be green and it's for statements that will be executed when condition is true
// the connect point is for what ever nodes come after the if stamtements may be an else statement too
class IfNode extends InputOutputNode {
  IfNode({super.position = Offset.zero})
      : super(
        image: '',
          color: Colors.green,
          width: 200,
          height: 200,
          connectionPoints: [
            InputConnectionPoint(position: Offset.zero, width: 20),
            OutputConnectionPoint(position: Offset.zero, width: 20),
            ConnectConnectionPoint(
                position: Offset.zero, isTop: true, width: 20),
            ConnectConnectionPoint(
                position: Offset.zero, isTop: false, width: 20),
          ],
        );

  @override
  Result<bool> execute([Entity? activeEntity]) {
    if (input != null) {
      Result<bool> conditionResult =
          input!.execute(activeEntity) as Result<bool>;
      if (conditionResult.errorMessage != null) {
        return Result.failure(errorMessage: conditionResult.errorMessage);
      }
      if (conditionResult.result != null && !conditionResult.result!) {
        return Result.success(result: false);
      }
    }

    if (output != null) {
      Result statementResult = output!.execute(activeEntity);
      if (statementResult.errorMessage != null) {
        return Result.failure(errorMessage: statementResult.errorMessage);
      }
    }

    return Result.success(result: true);
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
        value: this, child: IfNodeWidget(nodeModel: this));
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
  }) {
    return IfNode(position: position ?? this.position)
      ..isConnected = isConnected ?? this.isConnected
      ..child = child
      ..parent = parent
      ..input = input ?? this.input?.copy()
      ..output = output ?? this.output?.copy()
      ..connectionPoints = List<ConnectionPointModel>.from(
          connectionPoints.map((cp) => cp.copy()));
  }

  static IfNode fromJson(Map<String, dynamic> json) {
    return IfNode(
      position: OffsetJson.fromJson(json['position']),
    )..id = json['id']; // preserve id for linking
  }

  @override
  IfNode copy() {
    return copyWith(
      position: position,
      color: color,
      width: width,
      height: height,
      isConnected: isConnected,
      child: child?.copy(),
      parent: parent?.copy(),
      input: input?.copy(),
      output: output?.copy(),
    ) as IfNode;
  }
}
