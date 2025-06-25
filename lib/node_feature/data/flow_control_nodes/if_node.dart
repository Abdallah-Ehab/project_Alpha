import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/flow_control/if_node_widget.dart';



//Todo the if node will have 4 connection points (input, output, connect,connect)
//the input will be red and it's for the conditions
// the output will be green and it's for statements that will be executed when condition is true
// the connect point is for what ever nodes come after the if stamtements may be an else statement too
class IfNode extends InputOutputNode {
  IfNode(
      {
      super.position,
      required super.color,
      required super.width,
      required super.height,
      }) : super(connectionPoints: [
        InputConnectionPoint(position: Offset.zero, width: 50),
        OutputConnectionPoint(position: Offset.zero, width: 50),
        ConnectConnectionPoint(position: Offset.zero, isTop: true, width: 50),
        ConnectConnectionPoint(position: Offset.zero, isTop: false, width: 50),
      ]);

  // it has input slot for condition or condition group we can make it so condition is a condition group by using inheritance :) I don't know what Iam doing anymore
  // it has output slot same as condition group it just goes over the statments one by one and execute if true

  @override
  Result<bool> execute([Entity? activeEntity]) {
    if (input != null) {
      Result<bool> conditionResult = input!.execute(activeEntity) as Result<
          bool>; // this will execute all of the conditions to see if they are true or false using the conditions and the logic operators like && or || or not etc...
      if (conditionResult.errorMessage != null) {
        return Result.failure(errorMessage: conditionResult.errorMessage);
      }
      if (conditionResult.result != null && !conditionResult.result!) {
        log("false condition");
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
  NodeModel copyWith(
      {Offset? position,
      Color? color,
      double? width,
      double? height,
      bool? isConnected,
      NodeModel? child,
      NodeModel? parent}) {
    throw UnimplementedError();
  }
  
  @override
  IfNode copy() {
    return IfNode(
      position: position,
      color: color,
      width: width,
      height: height,
    )
      ..isConnected = isConnected
      ..child = child?.copy()
      ..parent = parent?.copy()
      ..input = input?.copy()
      ..output = output?.copy();
  }
}



