// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/block_feature/presentation/block_factory.dart';
import 'package:scratch_clone/block_feature/presentation/condition_block_widget.dart';
import 'package:scratch_clone/block_feature/presentation/declare_variable_block_widget.dart';
import 'package:scratch_clone/block_feature/presentation/if_block_widget.dart';
import 'package:scratch_clone/block_feature/presentation/move_block_widget.dart';
import 'package:scratch_clone/block_feature/presentation/play_animation_block_widget.dart';
import 'package:scratch_clone/block_feature/presentation/variable_reference_block_widget.dart';
import 'package:scratch_clone/core/result.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:uuid/uuid.dart';


abstract class BlockModel with ChangeNotifier {
  String id;
  Offset position;
  Color color;
  double width;
  double height;
  bool isConnected;
  BlockModel? child;
  BlockModel? parent;
  bool isDragTarget;
  bool isStatement;
  bool hasExecuted = false;

  BlockModel(
      {required this.position,
      required this.color,
      required this.width,
      required this.height,
      this.isDragTarget = true,
      this.isConnected = false,
      this.isStatement = false})
      : id = const Uuid().v4();

  BlockModel copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    BlockModel? child,
    BlockModel? parent,
    bool? isDragTarget,
  });

  void connectBlock(BlockModel childBlock) {
    child = childBlock;
    childBlock.parent = this;
    isConnected = true;
    childBlock.isConnected = true;
    notifyListeners();
  }

  void disconnectBlock() {
    if (parent != null) {
      parent!.child = null;
      parent!.isConnected = false;
      parent = null;
    }
    isConnected = false;
    notifyListeners();
  }

  void updatePosition(Offset newPosition) {
    position = newPosition;
    notifyListeners();
  }

  Result execute([Entity? activeEntity]);

  Widget buildBlock();

  void setWidth(double width) {
    this.width = width;
    notifyListeners();
  }

  void setHeight(double height) {
    this.height = height;
    notifyListeners();
  }

  void setIsStatement(bool isStatement) {
    this.isStatement = isStatement;
    notifyListeners();
  }
}

class StartBlock extends BlockModel {
  StartBlock(
      {required super.position,
      required super.color,
      required super.width,
      required super.height});

  @override
  BlockModel copyWith(
      {Offset? position,
      Color? color,
      double? width,
      double? height,
      bool? isConnected,
      BlockModel? child,
      BlockModel? parent,
      bool? isDragTarget}) {
    return StartBlock(
      position: position ?? this.position,
      color: color ?? this.color,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  Result<String> execute([Entity? activeEntity]) {
    return Result.success(result: "I'm just a cute starting block");
  }

  @override
  Widget buildBlock() {
    return StartBlockWidget(blockModel: this);
  }
}

class IfBlock extends BlockModel {
  List<ConditionBlock> conditions = [];
  List<BlockModel> statements = [];
  IfBlock({
    required super.position,
    required super.color,
    required super.width,
    required super.height,
    super.isDragTarget,
  });

  @override
  IfBlock copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    BlockModel? child,
    BlockModel? parent,
    bool? isDragTarget,
    List<ConditionBlock>? conditions,
    List<BlockModel>? statements,
  }) {
    return IfBlock(
      position: position ?? this.position,
      color: color ?? this.color,
      width: width ?? this.width,
      height: height ?? this.height,
      isDragTarget: isDragTarget ?? this.isDragTarget,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = child ?? this.child
      ..parent = parent ?? this.parent;
  }

  @override
  Result<bool> execute([Entity? activeEntity]) {
    for (var condition in conditions) {
      Result conditionResult = condition.execute(activeEntity);
      if (conditionResult.errorMessage != null) {
        return Result.failure(errorMessage: conditionResult.errorMessage);
      }
      if (conditionResult.result != null && !conditionResult.result!) {
        log("false condition");
        return Result.success(result: false);

      }
    }

    for (var statement in statements) {
      log("executing statement ${statement.runtimeType}");
      Result statementResult = statement.execute(activeEntity);
      if (statementResult.errorMessage != null) {
        return Result.failure(errorMessage: statementResult.errorMessage);
      }
    }
    return Result.success(result: true);
  }

  void addConidition(ConditionBlock condition) {
    conditions.add(condition);
    notifyListeners();
  }

  void addStatement(BlockModel statement) {
    statements.add(statement);
    notifyListeners();
  }

  void removeStatement({required BlockModel statement}) {
    statements.remove(statement);
    notifyListeners();
  }

  void removeCondition({required ConditionBlock condition}) {
    conditions.remove(condition);
    notifyListeners();
  }

  @override
  Widget buildBlock() {
    return ChangeNotifierProvider.value(
        value: this, child: IfBlockWidget(blockModel: this));
  }
}

class PlayAnimationBlock extends BlockModel {
  String? trackName;

  PlayAnimationBlock({
    required super.position,
    required super.color,
    required super.width,
    required super.height,
    super.isDragTarget,
    this.trackName,
  });

  @override
  PlayAnimationBlock copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    BlockModel? child,
    BlockModel? parent,
    bool? isDragTarget,
    String? trackName,
  }) {
    return PlayAnimationBlock(
      position: position ?? this.position,
      color: color ?? this.color,
      width: width ?? this.width,
      height: height ?? this.height,
      isDragTarget: isDragTarget ?? this.isDragTarget,
      trackName: trackName ?? this.trackName,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = child ?? this.child
      ..parent = parent ?? this.parent;
  }

  void setTrackName(String trackName) {
    this.trackName = trackName;
    notifyListeners();
  }

  

  @override
  Result execute([Entity? activeEntity]) {
    if (hasExecuted) {
      log("block playanimation has already been executed");
      return Result.failure(errorMessage: "Block has already executed");
    }
    // First, validate the inputs
    if (trackName == null) {
      return Result.failure(errorMessage: "No trackName specified");
    }

    if (activeEntity == null) {
      return Result.failure(errorMessage: "Active entity not provided");
    }

    AnimationControllerComponent? animComponent =
        activeEntity.getComponent<AnimationControllerComponent>();

    if (animComponent != null) {
      if (animComponent.animationTracks.containsKey(trackName!)) {
        animComponent.setTrack(trackName!);
        hasExecuted = true;
        return Result.success(result: "Animation changed to $trackName");
      } else {
        return Result.failure(
            errorMessage: "Animation track '$trackName' does not exist");
      }
    } else {
      return Result.failure(
          errorMessage: "Entity does not have an AnimationControllerComponent");
    }
  }

  @override
  Widget buildBlock() {
    return ChangeNotifierProvider.value(
      value: this,
      child: PlayAnimationBlockWidget(blockModel: this),
    );
  }
}

class ConditionBlock extends BlockModel {
  dynamic firstOperand;
  dynamic secondOperand;
  dynamic comparisonOperator;

  ConditionBlock({
    required super.position,
    required super.color,
    required super.width,
    required super.height,
    super.isDragTarget,
    this.firstOperand,
    this.secondOperand,
    this.comparisonOperator,
  });

  @override
  ConditionBlock copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    BlockModel? child,
    BlockModel? parent,
    bool? isDragTarget,
    String? firstOperand,
    String? secondOperand,
    String? comparisonOperator,
  }) {
    return ConditionBlock(
      position: position ?? this.position,
      color: color ?? this.color,
      width: width ?? this.width,
      height: height ?? this.height,
      isDragTarget: isDragTarget ?? this.isDragTarget,
      firstOperand: firstOperand ?? this.firstOperand,
      secondOperand: secondOperand ?? this.secondOperand,
      comparisonOperator: comparisonOperator ?? this.comparisonOperator,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = child ?? this.child
      ..parent = parent ?? this.parent;
  }

  @override
  Result execute([Entity? activeEntity]) {
    double? op1;
    double? op2;
    if (firstOperand == null ||
        secondOperand == null ||
        comparisonOperator == null) {
      return Result.failure(errorMessage: "Missing operand or operator");
    }

    if (activeEntity!.variables.containsKey(firstOperand)) {
      op1 = activeEntity.variables[firstOperand];
    }
    if (activeEntity.variables.containsKey(secondOperand)) {
      secondOperand = activeEntity.variables[secondOperand];
    }
    switch (comparisonOperator) {
      case "==":
     
        if (firstOperand is String) {
          op1 = double.tryParse(firstOperand!);
        }
      if (secondOperand is String) {
          op2 = double.tryParse(secondOperand!);
        }
        return Result.success(result: firstOperand == secondOperand || op1 == op2 || firstOperand == op2 || op1 == secondOperand);
      case ">":
        if (secondOperand is String) {
          op2 = double.tryParse(secondOperand!);
        }
        return Result.success(result: op1! > op2!);
      case "<":
        double? op1 = double.tryParse(firstOperand!);
        double? op2 = double.tryParse(secondOperand!);
        if (op1 == null || op2 == null) {
          return Result.failure(errorMessage: "Operands are not numbers");
        }
        return Result.success(result: op1 < op2);
      default:
        return Result.failure(errorMessage: "Unknown operator");
    }
  }

  @override
  Widget buildBlock() {
    return ChangeNotifierProvider.value(
      value: this,
      child: ConditionBlockWidget(blockModel: this),
    );
  }

  void setFirstOperand(double value) {
    firstOperand = value.toString();
    notifyListeners();
  }

  void setSecondOperand(double value) {
    secondOperand = value.toString();
    notifyListeners();
  }

  void setFirstOperandAsString(String value) {
    firstOperand = value;
    notifyListeners();
  }

  void setSecondOperandAsString(String value) {
    secondOperand = value;
    notifyListeners();
  }

  void setComparisonOperator(String value) {
    comparisonOperator = value;
    notifyListeners();
  }
}

class MoveBlock extends BlockModel {
  double x;
  double y;

  MoveBlock({
    required super.position,
    required super.color,
    required super.width,
    required super.height,
    super.isDragTarget,
    this.x = 0.0,
    this.y = 0.0,
  });

  @override
  MoveBlock copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    BlockModel? child,
    BlockModel? parent,
    bool? isDragTarget,
    double? x,
    double? y,
  }) {
    return MoveBlock(
      position: position ?? this.position,
      color: color ?? this.color,
      width: width ?? this.width,
      height: height ?? this.height,
      isDragTarget: isDragTarget ?? this.isDragTarget,
      x: x ?? this.x,
      y: y ?? this.y,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = child ?? this.child
      ..parent = parent ?? this.parent;
  }

  @override
  Result<String> execute([Entity? activeEntity]) {
    if (activeEntity == null) {
      return Result.failure(errorMessage: "Active entity not provided");
    }
    activeEntity.move(x: x, y: y);
    return Result.success(
        result: "Moved by $x horizontally and by $y vertically");
  }

  void setXvalue(double x) {
    this.x = x;
    notifyListeners();
  }

  void setYvalue(double y) {
    this.y = y;
    notifyListeners();
  }

  @override
  Widget buildBlock() {
    return ChangeNotifierProvider.value(
      value: this,
      child: MoveBlockWidget(blockModel: this),
    );
  }
}

class DeclareVarableBlock extends BlockModel {
  String variableName;
  dynamic value;
  DeclareVarableBlock(
      {required this.value,
      this.variableName = "x",
      required super.position,
      required super.color,
      required super.width,
      required super.height,
      super.isDragTarget = true});

  @override
  Widget buildBlock() {
    return ChangeNotifierProvider.value(
        value: this, child: DeclareVariableBlockWidget(blockModel: this));
  }

  void setVariableName(String variableName) {
    this.variableName = variableName;
    notifyListeners();
  }

  void setVariableValue(dynamic value) {
    this.value = value;
    notifyListeners();
  }

  @override
  DeclareVarableBlock copyWith(
      {Offset? position,
      Color? color,
      double? width,
      double? height,
      bool? isConnected,
      BlockModel? child,
      BlockModel? parent,
      bool? isDragTarget,
      String? variableName,
      dynamic value}) {
    return DeclareVarableBlock(
        position: position ?? this.position,
        color: color ?? this.color,
        width: width ?? this.width,
        height: height ?? this.height,
        isDragTarget: isDragTarget ?? this.isDragTarget,
        variableName: variableName ?? this.variableName,
        value: value ?? this.value)
      ..isConnected = isConnected ?? this.isConnected
      ..child = child ?? this.child
      ..parent = parent ?? this.parent;
  }

  @override
  Result execute([Entity? activeEntity]) {
    if (activeEntity!.variables.containsKey(variableName)) {
      return Result.failure(
          errorMessage:
              "variable $variableName already declared in this scope");
    }

    activeEntity.addVariable(name: variableName, value: value);
    return Result.success(result: "variable $variableName was declared");
  }
}

class VariableReferenceBlock extends BlockModel {
  String variableName;

  VariableReferenceBlock(
      {this.variableName = "",
      required super.position,
      required super.color,
      required super.width,
      required super.height,
      super.isDragTarget = true});

  @override
  Widget buildBlock() {
    return ChangeNotifierProvider.value(
        value: this, child: VariableReferenceBlockWidget(blockModel: this));
  }

  void setVariableName(String variableName) {
    this.variableName = variableName;
    notifyListeners();
  }

  @override
  VariableReferenceBlock copyWith({
    Offset? position,
    Color? color,
    double? width,
    double? height,
    bool? isConnected,
    BlockModel? child,
    BlockModel? parent,
    bool? isDragTarget,
    String? variableName,
  }) {
    return VariableReferenceBlock(
      position: position ?? this.position,
      color: color ?? this.color,
      width: width ?? this.width,
      height: height ?? this.height,
      isDragTarget: isDragTarget ?? this.isDragTarget,
      variableName: variableName ?? this.variableName,
    )
      ..isConnected = isConnected ?? this.isConnected
      ..child = child ?? this.child
      ..parent = parent ?? this.parent;
  }

  @override
  Result execute([Entity? activeEntity]) {
    if (activeEntity == null) {
      return Result.failure(
          errorMessage: "No active entity to get variable from");
    }

    if (variableName.isEmpty) {
      return Result.failure(errorMessage: "Variable name is empty");
    }

    if (!activeEntity.variables.containsKey(variableName)) {
      return Result.failure(
          errorMessage: "Variable '$variableName' does not exist");
    }

    return Result.success(result: activeEntity.variables[variableName]);
  }
}
