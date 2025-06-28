import 'package:flutter/cupertino.dart';
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
          color: Colors.cyan,
          width: 200,
          height: 200,
          connectionPoints: [
            InputConnectionPoint(position: Offset.zero, width: 50),
            OutputConnectionPoint(position: Offset.zero, width: 50),
            ConnectConnectionPoint(
                position: Offset.zero, isTop: true, width: 50),
            ConnectConnectionPoint(
                position: Offset.zero, isTop: false, width: 50),
          ],
        );

  static WhileNode fromJson(Map<String, dynamic> json) => WhileNode(
        position: OffsetJson.fromJson(json['position']),
     
      );

  @override
  Result<bool> execute([Entity? activeEntity]) {
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
    return WhileNode(
      position: position ?? this.position,
     
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = child ?? this.child?.copy()
      ..parent = parent ?? this.parent?.copy()
      ..input = input ?? this.input?.copy()
      ..output = output ?? this.output?.copy()
      ..connectionPoints = connectionPoints ??
          List<ConnectionPointModel>.from(
              this.connectionPoints.map((cp) => cp.copy()));
  }

  @override
  WhileNode copy() {
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
    ) as WhileNode;
  }
}
