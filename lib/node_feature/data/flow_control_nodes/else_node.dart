import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/flow_control_node_widgets/else_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class ElseNode extends InputOutputNode {
  ElseNode({
    super.position,
    
  }) : super(
    image: '',
          color: Colors.blue,
          width: 200,
          height: 200,
          connectionPoints: [
            OutputConnectionPoint(position: Offset.zero, width: 50),
            ConnectConnectionPoint(position: Offset.zero, isTop: true, width: 50),
            ConnectConnectionPoint(position: Offset.zero, isTop: false, width: 50),
          ],
        );

    static ElseNode fromJson(Map<String, dynamic> json) {
    return ElseNode(
      position: OffsetJson.fromJson(json['position']),
      
    )..id = json['id'];
  }


  @override
  Result execute([Entity? activeEntity]) {
    if (output != null) {
      final statementResult = output!.execute(activeEntity);
      if (statementResult.errorMessage != null) {
        return Result.failure(errorMessage: statementResult.errorMessage);
      }
    }
    return Result.success(result: null); // Indicate successful execution
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: ElseNodeWidget(nodeModel: this),
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
    NodeModel? output,
    List<ConnectionPointModel>? connectionPoints,
  }) {
    return ElseNode(
      position: position ?? this.position,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = child ?? this.child?.copy()
      ..parent = parent ?? this.parent?.copy()
      ..output = output ?? this.output?.copy()
      ..connectionPoints = connectionPoints ?? List<ConnectionPointModel>.from(this.connectionPoints.map((cp) => cp.copy()));
  }

  @override
  ElseNode copy() {
    return copyWith(
      position: position,
      color: color,
      width: width,
      height: height,
      isConnected: isConnected,
      child: child?.copy(),
      parent: parent?.copy(),
      output: output?.copy(),
    ) as ElseNode;
  }
}