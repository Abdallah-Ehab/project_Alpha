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
            connectionPoints: [
              InputConnectionPoint(position: Offset.zero, width: 20),
            ],
            color: Colors.green,
            width: 200,
            height: 200);

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
    return StatementGroupNode(
      statements: statements ?? this.statements,
    )
      ..position = position ?? this.position
      ..parent = null
      ..child = null
      ..isConnected = isConnected ?? this.isConnected
      ..connectionPoints = connectionPoints ??
          List<ConnectionPointModel>.from(
              this.connectionPoints.map((cp) => cp.copy()));
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
  return StatementGroupNode(
    isHighlighted: json['isHighlighted'] ?? false,
    statements: (json['statements'] as List<Map<String,dynamic>>).map((e)=>NodeModel.fromJson(e)).toList(),
    position : OffsetJson.fromJson(json['position']) // we'll restore this later using IDs
  )
    ..id = json['id']
    
    ..isConnected = json['isConnected'] ?? false
    ..connectionPoints = (json['connectionPoints'] as List)
        .map((e) => ConnectionPointModel.fromJson(e))
        .toList();
    
}


}
