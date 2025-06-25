import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/output_node_widgets/statements_group_node_widget.dart';

class StatementGroupNode extends InputNode {
  final List<NodeModel> statements;
  bool isHighlighted;
  StatementGroupNode({
    this.isHighlighted = false,
    required this.statements,
    required super.position,
    required super.color,
    required super.width,
    required super.height,
  }) : super(connectionPoints: [InputConnectionPoint(position: Offset.zero, width:50)]);

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
      position: position ?? this.position,
      color: color ?? this.color,
      width: width ?? this.width,
      height: height ?? this.height,
    )
      ..parent = parent ?? this.parent
      ..child = child ?? this.child
      ..isConnected = isConnected ?? this.isConnected;
  }
  
 @override
StatementGroupNode copy() {
  return StatementGroupNode(
    isHighlighted: isHighlighted,
    statements: statements.map((s) => s.copy()).toList(),
    position: position,
    color: color,
    width: width,
    height: height,
  )
    ..isConnected = isConnected
    ..child = child
    ..parent = parent;
}

}
