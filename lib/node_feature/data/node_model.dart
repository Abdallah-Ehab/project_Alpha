import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:uuid/uuid.dart';


// we will have four types of nodes :
// 1- normal nodes has input, output, and connect on the 4 sides
// 2- output node has only one output 
// 3 - input node has only on input 
// 4- connect nodes has only 2 connects

abstract class NodeModel with ChangeNotifier {
  String id;
  Offset position;
  Color color;
  double width;
  double height;
  bool isConnected;
  NodeModel? child;
  NodeModel? parent;
  List<ConnectionPointModel> connectionPoints;

  NodeModel(
      {
      this.position = Offset.zero,
      required this.color,
      required this.width,
      required this.height,
      this.isConnected = false,
      required this.connectionPoints})
      : id = const Uuid().v4();

  
  NodeModel copy();

  NodeModel copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
  });

  void connectNode(NodeModel childNode) {
    child = childNode;
    childNode.parent = this;
    log('$this is connected to $childNode');
    notifyListeners();
  }

  void disconnectIfTop() {
  if (child != null) {
    child!.parent = null;
    child!.notifyListeners();
    child = null;
    notifyListeners();
  }
}

void disconnectIfBottom() {
  if (parent != null) {
    parent!.child = null;
    parent!.notifyListeners();
    parent = null;
    notifyListeners();
  }
}


  void updatePosition(Offset newPosition) {
    position = newPosition;
    notifyListeners();
  }

  Result execute([Entity? activeEntity]);

  Widget buildNode();

  void setWidth(double width) {
    this.width = width;
    notifyListeners();
  }

  void setHeight(double height) {
    this.height = height;
    notifyListeners();
  }

}

// //Todo this will have only one connection point which is 'connect' aka the 'grey' one
// class StartNode extends NodeModel {
//   StartNode(
//       {required super.position,
//       required super.color,
//       required super.width,
//       required super.height,
//       required super.connectionPoints});

//   @override
//   NodeModel copyWith(
//       {Offset? position,
//       Color? color,
//       double? width,
//       double? height,
//       bool? isConnected,
//       NodeModel? child,
//       NodeModel? parent,
//       bool? isDragTarget,
//       List<ConnectionPointModel>? connectionPoints}) {
//     return StartNode(
//         position: position ?? this.position,
//         color: color ?? this.color,
//         width: width ?? this.width,
//         height: height ?? this.height,
//         connectionPoints: connectionPoints ?? this.connectionPoints);
//   }

//   @override
//   Result<String> execute([Entity? activeEntity]) {
//     return Result.success(result: "I'm just a cute starting node");
//   }

//   @override
//   Widget buildNode() {
//     return StartNodeWidget(nodeModel: this);
//   }
// }











// class VariableReferenceNode extends NodeModel {
//   String variableName;

//   VariableReferenceNode(
//       {this.variableName = "",
//       required super.position,
//       required super.color,
//       required super.width,
//       required super.height});

//   @override
//   Widget buildNode() {
//     return ChangeNotifierProvider.value(
//         value: this, child: VariableReferenceNodeWidget(nodeModel: this));
//   }

//   void setVariableName(String variableName) {
//     this.variableName = variableName;
//     notifyListeners();
//   }

//   @override
//   VariableReferenceNode copyWith({
//     Offset? position,
//     Color? color,
//     double? width,
//     double? height,
//     bool? isConnected,
//     NodeModel? child,
//     NodeModel? parent,
//     bool? isDragTarget,
//     String? variableName,
//   }) {
//     return VariableReferenceNode(
//       position: position ?? this.position,
//       color: color ?? this.color,
//       width: width ?? this.width,
//       height: height ?? this.height,
//       isDragTarget: isDragTarget ?? this.isDragTarget,
//       variableName: variableName ?? this.variableName,
//     )
//       ..isConnected = isConnected ?? this.isConnected
//       ..child = child ?? this.child
//       ..parent = parent ?? this.parent;
//   }

//   @override
//   Result execute([Entity? activeEntity]) {
//     if (activeEntity == null) {
//       return Result.failure(
//           errorMessage: "No active entity to get variable from");
//     }

//     if (variableName.isEmpty) {
//       return Result.failure(errorMessage: "Variable name is empty");
//     }

//     if (!activeEntity.variables.containsKey(variableName)) {
//       return Result.failure(
//           errorMessage: "Variable '$variableName' does not exist");
//     }

//     return Result.success(result: activeEntity.variables[variableName]);
//   }
// }
