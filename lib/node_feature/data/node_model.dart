import 'package:flutter/material.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/condition_group_node.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/else_node.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/if_node.dart';
import 'package:scratch_clone/node_feature/data/math_nodes/add_node.dart';
import 'package:scratch_clone/node_feature/data/math_nodes/div_node.dart';
import 'package:scratch_clone/node_feature/data/math_nodes/mul_node.dart';
import 'package:scratch_clone/node_feature/data/math_nodes/subtract_node.dart';
import 'package:scratch_clone/node_feature/data/node_types.dart';
import 'package:scratch_clone/node_feature/data/object_property_nodes/get_property_node.dart';
import 'package:scratch_clone/node_feature/data/output_nodes/branch_node.dart';
import 'package:scratch_clone/node_feature/data/output_nodes/statement_group_node.dart';
import 'package:scratch_clone/node_feature/data/physics_related_nodes/collision_detection_node.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/apply_force_node.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/flip_node.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/move_for_node.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/move_node.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/move_towards_node.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/teleport_node.dart';
import 'package:scratch_clone/node_feature/data/spawn_node/destroy_entity_node.dart';
import 'package:scratch_clone/node_feature/data/spawn_node/spawn_node_at_position.dart';
import 'package:scratch_clone/node_feature/data/time_related_nodes/wait_for_node.dart';
import 'package:scratch_clone/node_feature/data/variable_related_nodes/declare_variable_node.dart';
import 'package:scratch_clone/node_feature/data/variable_related_nodes/decrement_variable_node.dart';
import 'package:scratch_clone/node_feature/data/variable_related_nodes/get_variable_node.dart';
import 'package:scratch_clone/node_feature/data/variable_related_nodes/incerement_variable_node.dart';
import 'package:scratch_clone/node_feature/data/variable_related_nodes/set_variable_node.dart';
import 'package:scratch_clone/node_feature/presentation/start_node_widget.dart';
import 'package:uuid/uuid.dart';

// we will have four types of nodes :
// 1- normal nodes has input, output, and connect on the 4 sides
// 2- output node has only one output
// 3 - input node has only on input
// 4- connect nodes has only 2 connects



abstract class NodeModel with ChangeNotifier {
  String id;
  Offset position;
  bool isStatement;
  Color color;
  String image;
  double width;
  double height;
  bool isConnected;
  NodeModel? child;
  NodeModel? parent;
  List<ConnectionPointModel> connectionPoints;

  NodeModel({
    this.position = Offset.zero,
    this.isStatement = false,
    this.image = '',
    required this.color,
    required this.width,
    required this.height,
    this.isConnected = false,
    required this.connectionPoints,
  }) : id = const Uuid().v4();

  /// Serializes the common base fields
  Map<String, dynamic> baseToJson() {
    final map = {
      'id': id,
      'position': {'dx': position.dx, 'dy': position.dy},
      'color': color.toARGB32(),
      'width': width,
      'height': height,
      'isConnected': isConnected,
      'connectionPoints': connectionPoints.map((e) => e.toJson()).toList(),
      'childId': child?.id,
      'parentId': parent?.id,
    };

    if (this is HasInput) {
      map['inputId'] = (this as HasInput).input?.id;
    }
    if (this is HasOutput) {
      map['outputId'] = (this as HasOutput).output?.id;
    }

    return map;
  }

  // static because it's abstract you know 
  static NodeModel fromJson(Map<String, dynamic> json) {
    final type = json['type'] ;

    switch (type) {
      case 'StartNode':
        return StartNode.fromJson(json);
      case 'MoveNode':
        return MoveNode.fromJson(json);
      case 'IfNode':
        return IfNode.fromJson(json);
      case 'ElseNode':
        return ElseNode.fromJson(json);
      case 'DeclareVariableNode':
        return DeclareVariableNode.fromJson(json);
      case 'ConditionGroupNode':
        return ConditionGroupNode.fromJson(json);
      case 'StatementGroupNode':
        return StatementGroupNode.fromJson(json);
      case 'SetVariableNode':
      return SetVariableNode.fromJson(json);
      case 'TeleportNode':
      return TeleportNode.fromJson(json);
      case 'GetPropertyFromEntityNode':
      return GetPropertyFromEntityNode.fromJson(json);
      case 'WaitForNode':
      return WaitForNode.fromJson(json);
      case 'ApplyForceNode':
      return ApplyForceNode.fromJson(json);
      case 'BranchNode':
      return BranchNode.fromJson(json);
      case 'SpawnAtNode':
      return SpawnAtNode.fromJson(json);
      case 'GetVariableNode':
      return GetVariableNode.fromJson(json);
      case 'AddNode':
      return AddNode.fromJson(json);
      case 'SubtractNode':
      return SubtractNode.fromJson(json);
      case 'DivideNode':
      return DivideNode.fromJson(json);
      case 'MultiplyNode':
      return MultiplyNode.fromJson(json);
      case 'DestroyEntityNode':
      return DestroyEntityNode.fromJson(json);
      case 'DetectCollisionNode':
      return DetectCollisionNode.fromJson(json);
      case 'IncrementVariableNode':
      return IncrementVariableNode.fromJson(json);
      case 'DecrementVariableNode':
      return DecrementVariableNode.fromJson(json);
      case 'MoveForSecondsNode':
      return MoveForSecondsNode.fromJson(json);
      case 'SimpleFlipNode':
      return SimpleFlipNode.fromJson(json);
      case 'MoveTowardsNode':
      return MoveTowardsNode.fromJson(json);
      default:
        throw UnimplementedError('Unknown NodeModel type: $type');
    }
  }

  void reset(){
    return;
  }

  NodeModel copy();

  NodeModel copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    List<ConnectionPointModel>? connectionPoints,
  });

  /// Used for actual node logic
  Result execute([Entity? activeEntity,Duration? dt]);

  /// For rendering in the UI
  Widget buildNode();

  // updates the position
  void updatePosition(Offset newPosition) {
    position = newPosition;
    notifyListeners();
  }

  /// Visual config helpers
  void setWidth(double width) {
    this.width = width;
    notifyListeners();
  }

  void setHeight(double height) {
    this.height = height;
    notifyListeners();
  }

  /// Linking helper
  void connectNode(NodeModel childNode) {
    child = childNode;
    childNode.parent = this;
    notifyListeners();
  }

  void disconnectIfBottom({required ConnectionPointModel cp}) {
    if (child != null) {
      cp.isConnected = false;
      child!.parent = null;
      child = null;
      notifyListeners();
    }
  }

  void disconnectIfTop({required ConnectionPointModel cp}) {
    if (parent != null) {
      cp.isConnected = false;
      parent!.child = null;
      parent = null;
      notifyListeners();
    }
  }
}


class StartNode extends NodeModel {
  StartNode({
    super.position = Offset.zero,
  }) : super(
            color: Colors.orange,
            width: 200,
            height: 100,
            connectionPoints: []) {
    connectionPoints = [
      ConnectConnectionPoint(
        position: Offset.zero,
        isTop: false,
        width: 30,
        ownerNode: this,
      ),
    ];
  }

  @override
  NodeModel copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    NodeModel? child,
    NodeModel? parent,
    List<ConnectionPointModel>? connectionPoints,
  }) {
    final newNode = StartNode(position: position ?? this.position);
    newNode.isConnected = isConnected ?? this.isConnected;
    newNode.child = null;
    newNode.parent = null;

    newNode.connectionPoints = connectionPoints ??
        this.connectionPoints.map((e) => e.copyWith(ownerNode:newNode)).toList();

    return newNode;
  }

  @override
  Map<String, dynamic> baseToJson() {
    final base = super.baseToJson();
    base['type'] = 'StartNode';
    return base;
  }

  static StartNode fromJson(Map<String, dynamic> json) {
    final positionMap = json['position'] as Map<String, dynamic>;
    final position = Offset(positionMap['dx'], positionMap['dy']);

    final connectionPointsJson = json['connectionPoints'] as List<dynamic>;
    final startNode = StartNode(
      position: position,
    )
      ..id = json['id']
      ..width = (json['width'] as num).toDouble()
      ..height = (json['height'] as num).toDouble()
      ..isConnected = json['isConnected'] as bool
      ..child = null
      ..parent = null;

    final connectionPoints = connectionPointsJson
        .map((e) => ConnectionPointModel.fromJson(e, startNode))
        .toList();

    startNode.connectionPoints = connectionPoints;
    return startNode;
  }

  @override
  Result<String> execute([Entity? activeEntity,Duration? dt]) {
    return Result.success(result: "I'm just a cute starting node");
  }

  @override
  Widget buildNode() {
    return StartNodeWidget(nodeModel: this);
  }

  @override
  NodeModel copy() {
    final startNodeCopy = copyWith();
    return startNodeCopy;
  }
}

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
