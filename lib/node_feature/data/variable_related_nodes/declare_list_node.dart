
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/variable_related_node_widgets/declare_list_node_widget.dart';

class DeclareListNode extends NodeModel {
  String listName;

  DeclareListNode({this.listName = "myList", super.position = Offset.zero})
      : super(
          connectionPoints: [],
          color: Colors.deepPurple,
          width: 200,
          height: 100,
        );

  @override
  Result execute([Entity? activeEntity,Duration? dt]) {
    if (activeEntity == null) {
      return Result.failure(errorMessage: "No entity found");
    }
    if (activeEntity.lists.containsKey(listName)) {
      return Result.failure(errorMessage: "List '$listName' already exists");
    }
    activeEntity.addList(listName);
    return Result.success(result: "List '$listName' declared.");
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: DeclareListNodeWidget(node: this),
    );
  }

  @override
  DeclareListNode copyWith(
      {Offset? position,
      Color? color,
      double? width,
      double? height,
      bool? isConnected,
      NodeModel? child,
      NodeModel? parent,
      List<ConnectionPointModel>? connectionPoints,
      String? listName}) {
    return DeclareListNode(listName: listName ?? this.listName)
      ..position = position ?? this.position
      ..isConnected = isConnected ?? this.isConnected
      ..child = null
      ..parent = null
      ..connectionPoints = connectionPoints ??
          List<ConnectionPointModel>.from(
              this.connectionPoints.map((cp) => cp.copy()));
  }

  @override
  DeclareListNode copy() {
    final declareListNodeCopy = copyWith();
    return declareListNodeCopy;
  }

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'DeclareListNode';
    map['listName'] = listName;
    return map;
  }

  static DeclareListNode fromJson(Map<String, dynamic> json) {
    final node = DeclareListNode(
      listName: json['listName'] ?? 'myList',
    )
      ..id = json['id']
      ..isConnected = json['isConnected'] ?? false;

    node.connectionPoints = (json['connectionPoints'] as List)
        .map((e) => ConnectionPointModel.fromJson(e, node))
        .toList();
    return node;
}

}
