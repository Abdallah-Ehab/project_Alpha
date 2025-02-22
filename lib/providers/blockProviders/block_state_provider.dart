import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:scratch_clone/models/blockModels/block_interface.dart';
import 'package:scratch_clone/models/blockModels/block_model.dart';
import 'package:scratch_clone/models/blockModels/block_model.dart' as custom;

class BlockStateProvider extends ChangeNotifier {
  late BlockModel _selectedBlock;
  late BlockModel _parentBlock;
  final List<ConditionBlock> _conditionBlocks = [];
  final List<BlockModel> _storedBlocks = [
    IfStatementBlock(
      code: "if",
      color: Colors.red,
      source: Source.storage,
      state: custom.ConnectionState.disconnected,
      blockType: BlockType.input,
      width: 220.0,
      height: 75.0,
    ),
    PlayAnimationBlock(
      code: "Play",
      color: Colors.green,
      source: Source.storage,
      state: custom.ConnectionState.disconnected,
      blockType: BlockType.output,
      width: 150.0,
      height: 25.0,
    ),
    BlockModel(
      code: "Generic Block",
      color: Colors.orange,
      source: Source.storage,
      state: custom.ConnectionState.disconnected,
      blockType: BlockType.inputoutput,
      width: 100.0,
      height: 25.0,
    ),
    ConditionBlock(
        code: "code",
        color: Colors.purple,
        state: custom.ConnectionState.disconnected,
        blockType: BlockType.input,
        width: 10,
        height: 20,
        source: Source.storage),
    ChangePositionBlock(
      code: "MoveObject",
      color: Colors.blue,
      state: custom.ConnectionState.disconnected,
      blockType: BlockType.input,
      width: 200,
      height: 100,
      source: Source.storage,
      dx: 0.0,
      dy: 0.0,
    )
  ];

  List<ConditionBlock> get conditionBlocks => _conditionBlocks;

  void addToListOfConditionBlocks(ConditionBlock block) {
    _conditionBlocks.add(block);
    notifyListeners();
  }

  List<BlockModel> get storedBlocks => _storedBlocks;

  BlockModel get selectedBlock => _selectedBlock;

  set selectedBlock(BlockModel block) {
    _selectedBlock = block;
    notifyListeners();
  }

  BlockModel get parentBlock => _parentBlock;

  set parentBlock(BlockModel block) {
    _parentBlock = block;
    notifyListeners();
  }

  void connectBlock(BlockModel parent, BlockModel child) {
    parent.connectChild(child);
    log("${child.blockId} is connected to ${parent.blockId}");
    notifyListeners();
  }

  void connectInternalBlock(HasInternalBlock parent, BlockModel block) {
    parent.connectInternalBlock(block);
    log("${block.blockId} is connected internally to ${parent.toString()}");
    notifyListeners();
  }

  void disconnectBlock(BlockModel selectedBlock) {
    if (selectedBlock.parent != null) {
      selectedBlock.parent!.child = null;
      selectedBlock.parent = null;
    }
    selectedBlock.state = custom.ConnectionState.disconnected;
    notifyListeners();
  }

  void updateParentBlock(BlockModel block) {
    parentBlock.child = block;
    notifyListeners();
  }

  void updateBlockPosition(BlockModel block, Offset localOffset) {
    block.position = localOffset;
    notifyListeners();
  }
}
