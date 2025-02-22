import 'package:flutter/material.dart';
import 'package:scratch_clone/models/blockModels/block_interface.dart';
import 'package:scratch_clone/models/gameObjectModels/game_object.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';
import 'package:scratch_clone/widgets/blockWidgets/block_factory.dart';
import 'package:scratch_clone/widgets/blockWidgets/condition_draggable_block.dart';
import 'package:uuid/uuid.dart';

enum BlockType { input, output, inputoutput }

enum ConnectionState { connected, disconnected }

enum Source { storage, workSpace }

Uuid uuid = const Uuid();

class BlockModel implements BlockInterface {
  String? blockId;
  String code;
  Color color;
  Offset? position;
  ConnectionState state;
  BlockType blockType;
  double width;
  double height;
  Source source;
  BlockModel? child;
  BlockModel? parent;
  bool isDragTarget;
  BlockModel(
      {required this.code,
      required this.color,
      this.position,
      required this.state,
      required this.blockType,
      required this.width,
      required this.height,
      required this.source,
      this.child,
      this.parent,
      this.isDragTarget = true}) {
    blockId = uuid.v4();
  }

  @override
  bool operator ==(covariant BlockModel other) {
    if (identical(this, other)) return true;

    return other.color == color &&
        other.position == position &&
        other.state == state &&
        other.blockType == blockType &&
        other.width == width &&
        other.height == height &&
        other.source == source &&
        other.child == child &&
        other.parent == parent &&
        other.code == code;
  }

  @override
  int get hashCode {
    return color.hashCode ^
        position.hashCode ^
        state.hashCode ^
        blockType.hashCode ^
        width.hashCode ^
        height.hashCode ^
        source.hashCode ^
        child.hashCode ^
        parent.hashCode ^
        code.hashCode;
  }

  BlockModel copyWith(
      {int? blockId,
      Color? color,
      Offset? position,
      ConnectionState? state,
      BlockType? blockType,
      double? width,
      double? height,
      Source? source,
      BlockModel? child,
      BlockModel? parent,
      String? code}) {
    return BlockModel(
        color: color ?? this.color,
        position: position ?? this.position,
        state: state ?? this.state,
        blockType: blockType ?? this.blockType,
        width: width ?? this.width,
        height: height ?? this.height,
        source: source ?? this.source,
        child: child ?? this.child,
        parent: parent ?? this.parent,
        code: code ?? "",
        isDragTarget: true);
  }

  @override
  Result execute(
      GameObjectManagerProvider gameObjectProvider, GameObject gameObject) {
    return Result.success(
        result: "Iam just a generic block of the gameObject $gameObject");
  }

  @override
  void connectChild(BlockModel child) {
    this.child = child.copyWith(
        position: (position ?? Offset.zero) + Offset(0.5*width - 0.5*child.width,height),
        parent: this,
        state: ConnectionState.connected,
        source: Source.workSpace);
  }

  @override
  Widget constructBlock() {
    return GenericBlockWidget(blockModel: this);
  }
}

class IfStatementBlock extends BlockModel
    implements HasInternalBlock<ConditionBlock>, LabelBlock {
  ConditionBlock? condition;
  IfStatementBlock(
      {this.condition,
      required super.code,
      required super.color,
      required super.state,
      required super.blockType,
      required super.width,
      required super.height,
      required super.source,
      super.child,
      super.parent,
      super.position,
      super.isDragTarget = true}) {
    blockId = uuid.v4();
  }

  @override
  IfStatementBlock copyWith({
    ConditionBlock? condition,
    int? blockId,
    String? code,
    Color? color,
    Offset? position,
    ConnectionState? state,
    BlockType? blockType,
    double? width,
    double? height,
    Source? source,
    BlockModel? child,
    BlockModel? parent,
  }) {
    return IfStatementBlock(
        condition: condition ?? this.condition,
        code: code ?? this.code,
        color: color ?? this.color,
        position: position ?? this.position,
        state: state ?? this.state,
        blockType: blockType ?? this.blockType,
        width: width ?? this.width,
        height: height ?? this.height,
        source: source ?? this.source,
        child: child ?? this.child,
        parent: parent ?? this.parent,
        isDragTarget: true);
  }

  @override
  Result<bool> execute(
      GameObjectManagerProvider gameObjectProvider, GameObject gameObject) {
    if (condition != null) {
      if (condition!.execute(gameObjectProvider, gameObject).errorMessage !=
          null) {
        return Result.failure(
            errorMessage: condition!
                .execute(gameObjectProvider, gameObject)
                .errorMessage);
      }
      if (condition!.execute(gameObjectProvider, gameObject).result) {
        return Result.success(result: true);
      } else {
        return Result.success(result: false);
      }
    } else {
      return Result.failure(errorMessage: "missed condition");
    }
  }

  @override
  void connectChild(BlockModel child) {
    this.child = child.copyWith(
        position: (position ?? Offset.zero) + Offset(0.5*width - 0.5*child.width, height),
        parent: this,
        state: ConnectionState.connected,
        source: Source.workSpace);
  }

  @override
  void connectInternalBlock(ConditionBlock? block) {
    condition = block;
  }

  @override
  Widget constructBlock() {
    return IfBlockWidget(blockModel: this);
  }

  @override
  void registerLabel(GameObjectManagerProvider gameObejctManagerProvider) {}
}

class PlayAnimationBlock extends BlockModel {
  String? trackName;

  PlayAnimationBlock(
      {required super.code,
      required super.color,
      required super.state,
      required super.blockType,
      required super.width,
      required super.height,
      required super.source,
      super.child,
      super.parent,
      this.trackName,
      super.position,
      super.isDragTarget = true});
  @override
  PlayAnimationBlock copyWith({
    String? trackName,
    int? blockId,
    String? code,
    Color? color,
    Offset? position,
    ConnectionState? state,
    BlockType? blockType,
    double? width,
    double? height,
    Source? source,
    BlockModel? child,
    BlockModel? parent, // Add these two parameters
  }) {
    return PlayAnimationBlock(
        trackName: trackName ?? this.trackName,
        code: code ?? this.code,
        color: color ?? this.color,
        position: position ?? this.position,
        state: state ?? this.state,
        blockType: blockType ?? this.blockType,
        width: width ?? this.width,
        height: height ?? this.height,
        source: source ?? this.source,
        child: child ?? this.child, // Include these in the constructor call
        parent: parent ?? this.parent,
        isDragTarget: true);
  }

  @override
  Result execute(
      GameObjectManagerProvider gameObjectProvider, GameObject gameObject) {
    if (trackName == null) {
      return Result.failure(errorMessage: "no trackName specified");
    }
    gameObjectProvider.playAnimation(
        trackName: trackName!, gameObject: gameObject);
    return Result.success(result: "animation played succesffully");
  }

  @override
  Widget constructBlock() {
    return PlayAnimationBlockWidget(blockModel: this);
  }

  @override
  void connectChild(BlockModel child) {
    this.child = child.copyWith(
        position: (position ?? Offset.zero) + Offset(0.5*width - 0.5*child.width, height),
        parent: this,
        state: ConnectionState.connected,
        source: Source.workSpace);
  }
}

class ConditionBlock extends BlockModel {
  String? firstValue;
  String? secondValue;
  String? comaparisonOperator;

  ConditionBlock(
      {this.firstValue,
      this.secondValue,
      this.comaparisonOperator,
      required super.code,
      required super.color,
      required super.state,
      required super.blockType,
      required super.width,
      required super.height,
      required super.source,
      super.position,
      super.isDragTarget = false});

  @override
  Result execute(
      GameObjectManagerProvider gameObjectProvider, GameObject gameObject) {
    if (firstValue == null ||
        secondValue == null ||
        comaparisonOperator == null) {
      return Result.failure(
        errorMessage:
            "Missing first value, second value, or comparison operator in the condition block",
      );
    }

    num? num1 = num.tryParse(firstValue!);
    num? num2 = num.tryParse(secondValue!);

    bool result;

    switch (comaparisonOperator) {
      case '==':
        result = num1 != null && num2 != null
            ? num1 == num2
            : firstValue == secondValue;
        break;
      case '!=':
        result = num1 != null && num2 != null
            ? num1 != num2
            : firstValue != secondValue;
        break;
      case '>':
        result = num1 != null && num2 != null ? num1 > num2 : false;
        break;
      case '<':
        result = num1 != null && num2 != null ? num1 < num2 : false;
        break;
      case '>=':
        result = num1 != null && num2 != null ? num1 >= num2 : false;
        break;
      case '<=':
        result = num1 != null && num2 != null ? num1 <= num2 : false;
        break;
      default:
        return Result.failure(
            errorMessage: "Invalid comparison operator: $comaparisonOperator");
    }

    return Result.success(result: result);
  }

  @override
  Widget constructBlock() {
    return ConditionDraggableBlockWidget(blockModel: this);
  }
}

class ChangePositionBlock extends BlockModel {
  double? dx;
  double? dy;
  ChangePositionBlock(
      {required super.code,
      required super.color,
      required super.state,
      required super.blockType,
      required super.width,
      required super.height,
      required super.source,
      super.child,
      this.dx,
      this.dy});

    @override
  Result<Offset> execute(
      GameObjectManagerProvider gameObjectProvider, GameObject gameObject) {
        if(dx == null && dy == null){
          return Result.failure(errorMessage: "both the horisontal and vertical factors are null");
        }
    gameObjectProvider.changeGlobalPosition(dx:dx,dy:dy,gameObject: gameObject);
    return Result.success(result: gameObject.position);
  }
  @override
  Widget constructBlock() {
    return ChangePositionBlockWidget(blockModel: this);
  }
  
}

class Result<T> {
  T? result;
  String? errorMessage;

  Result.success({this.result});

  Result.failure({this.errorMessage});
}
