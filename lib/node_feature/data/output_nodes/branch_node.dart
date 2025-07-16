import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/else_node.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/if_node.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/data/time_related_nodes/wait_for_node.dart';
import 'package:scratch_clone/node_feature/presentation/output_node_widgets/branch_node_widget.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

class BranchNode extends OutputNode {
  NodeModel? _currentBranchNode;
  BranchNode({
    super.position = Offset.zero,
  }) : super(
          image: 'assets/icons/branchNode.png',
          connectionPoints: [],
          color: Colors.purple,
          width: 200,
          height: 100,
        ) {
    connectionPoints = [
      InputConnectionPoint(position: Offset.zero, width: 20, ownerNode: this),
      ConnectConnectionPoint(position: Offset.zero, isTop: false, width: 20, ownerNode: this),
    ];
  }

  @override
  Result execute([Entity? activeEntity, Duration? dt]) {


    _currentBranchNode ??= child;

    while (_currentBranchNode != null) {
      final result = _currentBranchNode!.execute(activeEntity, dt);

      if (result.errorMessage != null) {
        return Result.failure(errorMessage: result.errorMessage);
      }

      // Handle wait node - stay on current node
      if (_currentBranchNode is WaitForNode &&
          result is Result<bool> &&
          result.result == false) {
        return Result.success(result: false); // Still waiting, don't advance
      }

      // Handle IfNode false branch
      if (_currentBranchNode is IfNode &&
          result is Result<bool> &&
          result.result == false) {
        final elseNode = _currentBranchNode!.child;
        if (elseNode is ElseNode) {
          final elseResult = elseNode.execute(activeEntity, dt);
          if (elseResult.errorMessage != null) {
            return Result.failure(errorMessage: elseResult.errorMessage);
          }
          _currentBranchNode = elseNode.child;
          continue;
        }
      }

      _currentBranchNode = _currentBranchNode!.child;
    }

    // Branch completed, reset for next iteration
    _currentBranchNode = null;
    return Result.success(result: true); // Finished branch
  
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(value: this,child: BranchNodeWidget(node: this),);
  }

  @override
  BranchNode copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    NodeModel? parent,
    NodeModel? child,
    bool? isConnected,
    List<ConnectionPointModel>? connectionPoints,
  }) {
    final newNode = BranchNode(
      position: position ?? this.position,
    )
      ..parent = null
      ..child = null
      ..isConnected = isConnected ?? this.isConnected;

    newNode.connectionPoints = connectionPoints != null
        ? connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList()
        : this.connectionPoints.map((cp) => cp.copyWith(ownerNode: newNode)).toList();

    return newNode;
  }

  @override
  BranchNode copy() => copyWith();

  @override
  Map<String, dynamic> baseToJson() {
    final map = super.baseToJson();
    map['type'] = 'BranchNode';
    return map;
  }

  static BranchNode fromJson(Map<String, dynamic> json) {
    final node = BranchNode(
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
