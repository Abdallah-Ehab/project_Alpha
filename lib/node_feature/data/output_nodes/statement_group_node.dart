import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/presentation/output_node_widgets/statements_group_node_widget.dart';

class StatementGroupNode extends OutputNode {
  final List<NodeModel> statements;
  bool isHighlighted;
  StatementGroupNode({
    this.isHighlighted = false,
    required this.statements,
  }) : super(image:'',connectionPoints: [InputConnectionPoint(position: Offset.zero, width:20),], position: Offset.zero,color: Colors.green,width: 200, height: 200);

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

  void highlightNode(bool highlight){
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
    )..position = position ?? this.position
      ..parent = parent ?? this.parent
      ..child = child ?? this.child
      ..isConnected = isConnected ?? this.isConnected
      ..connectionPoints = connectionPoints ?? List<ConnectionPointModel>.from(this.connectionPoints.map((cp) => cp.copy()));
  }

  @override
  StatementGroupNode copy() {
    return StatementGroupNode(
      isHighlighted: isHighlighted,
      statements: statements.map((s) => s.copy()).toList(),
    )
      ..isConnected = isConnected
      ..child = child
      ..parent = parent
      ..connectionPoints = List<ConnectionPointModel>.from(connectionPoints.map((cp) => cp.copy()));
  }
}
