import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';
import 'package:scratch_clone/node_feature/presentation/player_transform_node_widgets/move_node_widget.dart';

// Todo the move node will have 2 connection points (connect, connect) it doesn't have an input or output it will just be connected
class MoveNode extends NodeModel {
  double x;
  double y;

  MoveNode({
    this.x = 0.0,
    this.y = 0.0,
  }) : super(
          connectionPoints: [
            ConnectConnectionPoint(
                position: Offset.zero, isTop: true, width: 20),
            ConnectConnectionPoint(
                position: Offset.zero, isTop: false, width: 20),
          ],
        position: Offset.zero,color: Colors.blue,width: 100, height: 50);

  @override
  Result<String> execute([Entity? activeEntity]) {
    if (activeEntity == null) {
      return Result.failure(errorMessage: "Active entity not provided");
    }
    activeEntity.move(x: x, y: y);
    return Result.success(
        result: "Moved by $x horizontally and by $y vertically");
  }

  void setX(double value) {
    x = value;
    notifyListeners();
  }

  void setY(double value) {
    y = value;
    notifyListeners();
  }

  @override
  Widget buildNode() {
    return ChangeNotifierProvider.value(
      value: this,
      child: MoveNodeWidget(
        node: this,
      ),
    );
  }

  @override
  MoveNode copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    List<ConnectionPointModel>? connectionPoints,
    double? x,
    double? y,
  }) {
    return MoveNode(
      x: x ?? this.x,
      y: y ?? this.y,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = child ?? this.child?.copy()
      ..parent = parent ?? this.parent?.copy()
      ..connectionPoints = connectionPoints ??
          List<ConnectionPointModel>.from(
              this.connectionPoints.map((cp) => cp.copy()));
  }

  @override
  MoveNode copy() {
    return copyWith(
      position: position,
      isConnected: isConnected,
      child: child?.copy(),
      parent: parent?.copy(),
      connectionPoints:
          List<ConnectionPointModel>.from(connectionPoints.map((cp) => cp.copy())),
      x: x,
      y: y,
    );
  }
}
