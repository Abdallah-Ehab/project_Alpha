import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/variable_related_node_widgets/declare_variable_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class DeclareVariableNode extends NodeModel {
  String variableName;
  dynamic value;

  DeclareVariableNode({
    this.variableName = "x",
    this.value = 0,
    super.position = Offset.zero
    
  }) : super(
          image: 'assets/icons/CreateVariableNode.png',
          connectionPoints: [],
          color: Colors.orange,width: 200,height: 100
        );


  void setVariableName(String newName) {
    variableName = newName;
    notifyListeners();
  }

  void setValue(dynamic newValue) {
    value = newValue;
    notifyListeners();
  }

  @override
  Result execute([Entity? activeEntity,Duration? dt]) {
    return Result.success(result: "Variable '$variableName' updated to $value.");
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: DeclareVarableNodeWidget(node: this),
    );
  }

  @override
  DeclareVariableNode copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    String? variableName,
    dynamic value,
    List<ConnectionPointModel>? connectionPoints,
  }) {
    return DeclareVariableNode(
      variableName: variableName ?? this.variableName,
      value: value ?? this.value,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = null
      ..parent = null
      ..connectionPoints = connectionPoints ??
          List<ConnectionPointModel>.from(this.connectionPoints.map((cp) => cp.copy()));
  }

  @override
  DeclareVariableNode copy() {
    return copyWith(
     
    );
  }

  @override
Map<String, dynamic> baseToJson() {
  final map = super.baseToJson();
  map['type'] = 'DeclareVariableNode';
  map['variableName'] = variableName;
  map['value'] = value;
  return map;
}

static DeclareVariableNode fromJson(Map<String, dynamic> json) {
  final node = DeclareVariableNode(
    variableName: json['variableName'] as String,
    value: json['value'],
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




