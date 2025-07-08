import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/output_node_widgets/statements_group_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class StatementGroupNode extends OutputNode {
  final List<NodeModel> statements;
  bool isHighlighted;
  StatementGroupNode({
    this.isHighlighted = false,
    required this.statements,
    super.position = Offset.zero
  }) : super(
            image: 'assets/icons/StatementGroupNode.png',
            connectionPoints: [],
            color: Colors.green,
            width: 200,
            height: 200) {
    connectionPoints = [
      InputConnectionPoint(position: Offset.zero, width: 20, ownerNode: this),
    ];
  }

  void addStatement(NodeModel node) {
    statements.add(node);
    _resize();
    notifyListeners();
  }

  void removeStatement(NodeModel node) {
    statements.remove(node);
    _resize();
    notifyListeners();
  }

  void _resize() {
    final double extraHeight = statements.length * 80;
    setHeight(100 + extraHeight);
  }

  @override
  Result execute([Entity? activeEntity]) {
    for (final node in statements) {
      final result = node.execute(activeEntity);
      if (result.errorMessage != null) {
        return Result.failure(errorMessage: result.errorMessage);
      }
    }
    return Result.success(result: true);
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: StatementGroupNodeWidget(node: this),
    );
  }

  void highlightNode(bool highlight) {
    isHighlighted = highlight;
    notifyListeners();
  }

  @override
StatementGroupNode copyWith({
  Offset? position,
  Color? color,
  double? width,
  double? height,
  NodeModel? parent,
  NodeModel? child,
  bool? isConnected,
  List<NodeModel>? statements,
  List<ConnectionPointModel>? connectionPoints,
}) {
  final newNode = StatementGroupNode(
    statements: statements ?? List<NodeModel>.from(this.statements.map((s) => s.copy())),
  )
    ..position = position ?? this.position
    ..parent = null
    ..child = null
    ..isConnected = isConnected ?? this.isConnected;

  newNode.connectionPoints = connectionPoints != null
      ? connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList()
      : this.connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList();

  return newNode;
}


  @override
  StatementGroupNode copy() {
    return copyWith();
  }

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'StatementGroupNode';
    map['isHighlighted'] = isHighlighted;
    map['statements'] =
        statements.map((node) => node.baseToJson()).toList(); // store IDs only
    return map;
  }

static StatementGroupNode fromJson(Map<String, dynamic> json) {
  final node = StatementGroupNode(
    isHighlighted: json['isHighlighted'] ?? false,
    statements: (json['statements'] as List<dynamic>)
        .map((e) => NodeModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    position: OffsetJson.fromJson(json['position']),
  )
    ..id = json['id']
    ..isConnected = json['isConnected'] ?? false
    ..child = null
    ..parent = null;

  node.connectionPoints = (json['connectionPoints'] as List)
      .map((e) => ConnectionPointModel.fromJson(e, node))
      .toList();

  return node;
}


}
