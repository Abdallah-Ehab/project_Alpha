
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';

// class TimerNode extends NodeModel {
//   double targetTime; // in seconds
//   double elapsedTime = 0.0;

//   TimerNode({
//     this.targetTime = 1.0, // default 1 second
//     super.position = Offset.zero,
//   }) : super(
//           color: Colors.indigo,
//           width: 200,
//           height: 100,
//           connectionPoints: [
//             ConnectConnectionPoint(position: Offset.zero, isTop: true, width: 20),
//             ConnectConnectionPoint(position: Offset.zero, isTop: false, width: 20),
//           ],
//         );

//   void setTargetTime(double seconds) {
//     targetTime = seconds;
//     notifyListeners();
//   }

//   void reset() {
//     elapsedTime = 0.0;
//   }

//   @override
//   Result<bool> execute([Entity? activeEntity, double? dt]) {
//     if (dt == null) {
//       return Result.failure(errorMessage: "Delta time (dt) is required.");
//     }

//     elapsedTime += dt;

//     if (elapsedTime >= targetTime) {
//       elapsedTime = 0.0;
//       return Result.success(result: true);
//     }

//     return Result.success(result: false);
//   }

//   @override
//   Widget buildNode() {
//     return ChangeNotifierProvider.value(
//       value: this,
//       child: TimerNodeWidget(node: this), // your custom widget
//     );
//   }

//   @override
//   TimerNode copyWith({
//     Offset? position,
//     Color? color,
//     double? width,
//     double? height,
//     bool? isConnected,
//     NodeModel? child,
//     NodeModel? parent,
//     List<ConnectionPointModel>? connectionPoints,
//     double? targetTime,
//   }) {
//     return TimerNode(
//       targetTime: targetTime ?? this.targetTime,
//       position: position ?? this.position,
//     )
//       ..isConnected = isConnected ?? this.isConnected
//       ..child = null
//       ..parent = null
//       ..elapsedTime = 0.0
//       ..connectionPoints = connectionPoints ?? List<ConnectionPointModel>.from(this.connectionPoints.map((cp) => cp.copy()));
//   }

//   @override
//   TimerNode copy() {
//     return copyWith();
//   }
// }
