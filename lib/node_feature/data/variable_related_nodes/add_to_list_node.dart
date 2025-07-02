import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/variable_related_node_widgets/add_to_list_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class AddToListNode extends NodeModel {
  String listName;
  dynamic value;

  AddToListNode({
    this.listName = '',
    this.value,
    super.position = Offset.zero
  }) : super(
          connectionPoints: [],
          color: Colors.green,
          width: 220,
          height: 120,
        );


  void setListName(String newName) {
    listName = newName;
    notifyListeners();
  }

  void setValue(dynamic newValue) {
    value = newValue;
    notifyListeners();
  }

  @override
  Result execute([Entity? activeEntity]) {
    if (activeEntity == null) return Result.failure(errorMessage: "No entity found");

    final list = activeEntity.lists[listName];
    if (list == null) {
      return Result.failure(errorMessage: "List '$listName' does not exist.");
    }

    list.add(value);
    return Result.success(result: "Value '$value' added to list '$listName'");
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: AddToListNodeWidget(node: this),
    );
  }

  @override
  AddToListNode copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    String? listName,
    dynamic value,
    List<ConnectionPointModel>? connectionPoints,
  }) {
    return AddToListNode(
      listName: listName ?? this.listName,
      value: value ?? this.value,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = null
      ..parent = null
      ..connectionPoints = connectionPoints ??
          List<ConnectionPointModel>.from(this.connectionPoints.map((cp) => cp.copy()));
  }

  @override
  AddToListNode copy() {
    return copyWith();
  }

  @override
Map<String, dynamic> baseToJson() {
  final map = super.baseToJson();
  map['type'] = 'AddToListNode';
  map['listName'] = listName;
  map['value'] = value;
  return map;
}

static AddToListNode fromJson(Map<String, dynamic> json) {
  return AddToListNode(
    listName: json['listName'] ?? '',
    value: json['value'],
    position: OffsetJson.fromJson(json['position'])
  )
    ..id = json['id']
    ..isConnected = json['isConnected'] ?? false
    ..connectionPoints = (json['connectionPoints'] as List)
        .map((e) => ConnectionPointModel.fromJson(e))
        .toList();
}

}
